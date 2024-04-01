//
//  ShapeEdge+Split.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iFixFloat
import iShape

extension Array where Element == ShapeEdge {
    
    func split(solver: Solver, range: LineRange) -> [Segment] {
        let isSmallRange = range.max - range.min < 128
        let isList: Bool
#if DEBUG
        isList = solver == .list || solver == .auto && (self.count < 1_000 || isSmallRange)
#else
        isList = solver == .list || solver == .auto && self.count < 1_000 || isSmallRange
#endif
        
        let rangeList = SplitRangeList(edges: self)
        if isList {
            var solver = SplitSolver(list: rangeList, scanStore: ScanSplitList(count: self.count))
            return solver.solve()
        } else {
            var solver = SplitSolver(list: rangeList, scanStore: ScanSplitTree(range: range, count: self.count))
            return solver.solve()
        }
    }
}

private struct SplitSolver<S: ScanSplitStore> {
    
    private var scanStore: S
    private var list: SplitRangeList
    
    init(list: SplitRangeList, scanStore: S) {
        self.list = list
        self.scanStore = scanStore
    }
    
    mutating func solve() -> [Segment] {
        
        var needToFix = true
        
        while needToFix {
            needToFix = false
            
            var this = list.first()

            while this.isNotNil {
                let thisEdge = list.edge(index: this.index)

                guard !thisEdge.count.isEmpty else {
                    this = list.removeAndNext(index: this.index)
                    continue
                }
                
                guard let scanResult = scanStore.intersectAndRemoveOther(this: thisEdge.xSegment) else {
                    scanStore.insert(segment: VersionSegment(vIndex: this, xSegment: thisEdge.xSegment))
                    this = list.next(index: this.index)
                    continue
                }

                let other = scanResult.other
                
                guard let scanEdge = list.validateEdge(vIndex: other) else {
                    continue
                }
                
                switch scanResult.cross {
                case .pure(let point):

                    this = self.pure(
                        point: point,
                        thisEdge: thisEdge,
                        this: this.index,
                        scanEdge: scanEdge,
                        other: other.index
                    )
                    needToFix = needToFix || thisEdge.xSegment.isNotSameLine(point) || scanEdge.xSegment.isNotSameLine(point)
                    
                case .otherEndExact(let point):
                    
                    this = self.divideThisExact(
                        point: point,
                        thisEdge: thisEdge,
                        this: this.index,
                        scanEdge: scanEdge,
                        scanVer: other
                    )
                    
                case .otherEndRound(let point):
                    
                    this = self.divideThisRound(
                        point: point,
                        thisEdge: thisEdge,
                        this: this.index,
                        scanEdge: scanEdge,
                        scanVer: other
                    )
                    
                    needToFix = true
                    
                case .targetEndExact(let point):

                    self.divideScanExact(
                        point: point,
                        thisEdge: thisEdge,
                        scanEdge: scanEdge,
                        other: other.index
                    )

                case .targetEndRound(let point):
                    
                    self.divideScanRound(
                        point: point,
                        thisEdge: thisEdge,
                        scanEdge: scanEdge,
                        other: other.index
                    )
                    
                    needToFix = true
                    
                case .endOverlap:
                    // segments are collinear
                    // 2 situation are possible
                    // this.a inside scan(other)
                    // or
                    // scan.b inside this
                    
                    if thisEdge.xSegment.b == scanEdge.xSegment.b {
                        // this.a inside scan(other)
                        
                        this = self.divideScanOverlap(
                            thisEdge: thisEdge,
                            this: this.index,
                            scanEdge: scanEdge,
                            other: other.index
                        )
                        
                        // scan.a < this.a
                        assert(Point.xLineCompare(a: scanEdge.xSegment.a, b: thisEdge.xSegment.a))
                    } else {
                        // scan.b inside this
                        
                        this = self.divideThisOverlap(
                            thisEdge: thisEdge,
                            this: this.index,
                            scanEdge: scanEdge,
                            other: other.index
                        )
                        
                        // scan.b < this.b
                        assert(Point.xLineCompare(a: scanEdge.xSegment.b, b: thisEdge.xSegment.b))
                    }
                case .overlap:
                    // segments are collinear
                    // 2 situation are possible
                    // this if fully inside scan(other)
                    // or
                    // partly overlap each other
                    
                    if Point.xLineCompare(a: scanEdge.xSegment.b, b: thisEdge.xSegment.b) {
                        // partly overlap
                        this = self.divideBothPartlyOverlap(
                            thisEdge: thisEdge,
                            this: this.index,
                            scanEdge: scanEdge,
                            other: other.index
                        )
                    } else {
                        assert(Point.xLineCompare(a: thisEdge.xSegment.b, b: scanEdge.xSegment.b))
                        // this inside scan
                        this = self.divideScanByThree(
                            thisEdge: thisEdge,
                            this: this.index,
                            scanEdge: scanEdge,
                            other: other.index
                        )
                    }
                }
            } // while
            
            scanStore.clear()
        } // while
        
        return list.segments()
    }
    
    private mutating func pure(point p: Point, thisEdge: ShapeEdge, this: DualIndex, scanEdge: ShapeEdge, other: DualIndex) -> VersionedIndex {
        // classic middle intersection, no ends, overlaps etc
        
        let thisLt = ShapeEdge.createAndValidate(a: thisEdge.xSegment.a, b: p, count: thisEdge.count)
        let thisRt = ShapeEdge.createAndValidate(a: p, b: thisEdge.xSegment.b, count: thisEdge.count)
        
        assert(thisLt.xSegment.isLess(thisRt.xSegment))
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: p, count: scanEdge.count)
        let scanRt = ShapeEdge.createAndValidate(a: p, b: scanEdge.xSegment.b, count: scanEdge.count)
        
        assert(scanLt.xSegment.isLess(scanRt.xSegment))
        
        let ltThis = list.addAndMerge(anchorIndex: this, newEdge: thisLt)
        _ = list.addAndMerge(anchorIndex: this, newEdge: thisRt)
        
        let ltScan = list.addAndMerge(anchorIndex: other, newEdge: scanLt)
        let rtScan = list.addAndMerge(anchorIndex: other, newEdge: scanRt)
        
        list.remove(index: this)
        list.remove(index: other)
        
        assert(thisLt.xSegment.a.x <= p.x)
        
        if ScanCrossSolver.isValid(scan: scanLt.xSegment, this: thisLt.xSegment) {
            scanStore.insert(segment: VersionSegment(vIndex: ltScan, xSegment: scanLt.xSegment))
        }

        if ScanCrossSolver.isValid(scan: scanRt.xSegment, this: thisLt.xSegment) {
            scanStore.insert(segment: VersionSegment(vIndex: rtScan, xSegment: scanRt.xSegment))
        }
        
        return ltThis
    }
    
    private mutating func divideThisExact(point p: Point, thisEdge: ShapeEdge, this: DualIndex, scanEdge: ShapeEdge, scanVer: VersionedIndex) -> VersionedIndex {
        let thisLt = ShapeEdge(xSegment: XSegment(a: thisEdge.xSegment.a, b: p), count: thisEdge.count)
        let thisRt = ShapeEdge(xSegment: XSegment(a: p, b: thisEdge.xSegment.b), count: thisEdge.count)
        
        assert(thisLt.xSegment.isLess(thisRt.xSegment))
        
        let ltThis = list.addAndMerge(anchorIndex: this, newEdge: thisLt)
        _ = list.addAndMerge(anchorIndex: ltThis.index, newEdge: thisRt)
        
        list.remove(index: this)
        
        if ScanCrossSolver.isValid(scan: scanEdge.xSegment, this: thisLt.xSegment) {
            scanStore.insert(segment: VersionSegment(vIndex: scanVer, xSegment: scanEdge.xSegment))
        }
        
        return ltThis
    }
    
    private mutating func divideThisRound(point p: Point, thisEdge: ShapeEdge, this: DualIndex, scanEdge: ShapeEdge, scanVer: VersionedIndex) -> VersionedIndex {
        let thisLt = ShapeEdge.createAndValidate(a: thisEdge.xSegment.a, b: p, count: thisEdge.count)
        let thisRt = ShapeEdge.createAndValidate(a: p, b: thisEdge.xSegment.b, count: thisEdge.count)
        
        assert(thisLt.xSegment.isLess(thisRt.xSegment))
        
        let ltThis = list.addAndMerge(anchorIndex: this, newEdge: thisLt)
        _ = list.addAndMerge(anchorIndex: ltThis.index, newEdge: thisRt)
        
        list.remove(index: this)
        
        if ScanCrossSolver.isValid(scan: scanEdge.xSegment, this: thisLt.xSegment) {
            scanStore.insert(segment: VersionSegment(vIndex: scanVer, xSegment: scanEdge.xSegment))
        }
        
        return ltThis
    }
    
    private mutating func divideScanExact(point p: Point, thisEdge: ShapeEdge, scanEdge: ShapeEdge, other: DualIndex) {
        // this segment-end divide scan(other) segment into 2 parts
        
        let scanLt = ShapeEdge(xSegment: XSegment(a: scanEdge.xSegment.a, b: p), count: scanEdge.count)
        let scanRt = ShapeEdge(xSegment: XSegment(a: p, b: scanEdge.xSegment.b), count: scanEdge.count)
        
        assert(scanLt.xSegment.isLess(scanRt.xSegment))
        
        let newScanLeft = list.addAndMerge(anchorIndex: other, newEdge: scanLt)
        let newScanRight = list.addAndMerge(anchorIndex: other, newEdge: scanRt)
        
        list.remove(index: other)

        if thisEdge.xSegment.a.x < p.x {
            // this < p
            scanStore.insert(segment: VersionSegment(vIndex: newScanLeft, xSegment: scanLt.xSegment))
        } else if scanRt.xSegment.isLess(thisEdge.xSegment) {
            // scanRt < this
            scanStore.insert(segment: VersionSegment(vIndex: newScanRight, xSegment: scanRt.xSegment))
        }
    }
    
    private mutating func divideScanRound(point p: Point, thisEdge: ShapeEdge, scanEdge: ShapeEdge, other: DualIndex) {
        // this segment-end divide scan(other) segment into 2 parts
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: p, count: scanEdge.count)
        let scanRt = ShapeEdge.createAndValidate(a: p, b: scanEdge.xSegment.b, count: scanEdge.count)
        
        assert(scanLt.xSegment.isLess(scanRt.xSegment))
        
        let newScanLeft = list.addAndMerge(anchorIndex: other, newEdge: scanLt)
        let newScanRight = list.addAndMerge(anchorIndex: other, newEdge: scanRt)
        
        list.remove(index: other)
        
        if thisEdge.xSegment.a.x < p.x {
            // this < p
            scanStore.insert(segment: VersionSegment(vIndex: newScanLeft, xSegment: scanLt.xSegment))
        } else if scanRt.xSegment.isLess(thisEdge.xSegment) {
            // scanRt < this
            scanStore.insert(segment: VersionSegment(vIndex: newScanRight, xSegment: scanRt.xSegment))
        }
    }
    
    private mutating func divideScanOverlap(thisEdge: ShapeEdge, this: DualIndex, scanEdge: ShapeEdge, other: DualIndex) -> VersionedIndex {
        // segments collinear
        // this.b == scan.b and scan.a < this.a < scan.b
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: thisEdge.xSegment.a, count: scanEdge.count)
        let merge = thisEdge.count.add(scanEdge.count)
        
        _ = list.addAndMerge(anchorIndex: other, newEdge: scanLt)
        _ = list.update(index: this, count: merge)
        
        list.remove(index: other)

        return list.next(index: this)
    }
    
    private mutating func divideThisOverlap(thisEdge: ShapeEdge, this: DualIndex, scanEdge: ShapeEdge, other: DualIndex) -> VersionedIndex {
        // segments collinear
        // this.a == scan.a and this.a < scan.b < this.b
        
        let merge = thisEdge.count.add(scanEdge.count)
        let thisRt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.b, b: thisEdge.xSegment.b, count: thisEdge.count)
        
        let newVersion = list.update(index: other, count: merge)
        _ = list.addAndMerge(anchorIndex: other, newEdge: thisRt)
        
        list.remove(index: this)
        
        let verIndex = VersionedIndex(version: newVersion, index: other)
        let verSegment = VersionSegment(vIndex: verIndex, xSegment: scanEdge.xSegment)
        scanStore.insert(segment: verSegment)

        return list.next(index: other)
    }
    
    private mutating func divideBothPartlyOverlap(thisEdge: ShapeEdge, this: DualIndex, scanEdge: ShapeEdge, other: DualIndex) -> VersionedIndex {
        // segments collinear
        // scan.a < this.a < scan.b < this.b
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: thisEdge.xSegment.a, count: scanEdge.count)
        let middle = ShapeEdge.createAndValidate(a: thisEdge.xSegment.a, b: scanEdge.xSegment.b, count: scanEdge.count.add(thisEdge.count))
        let thisRt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.b, b: thisEdge.xSegment.b, count: thisEdge.count)
        
        let lt = list.addAndMerge(anchorIndex: other, newEdge: scanLt).index
        let md = list.addAndMerge(anchorIndex: lt, newEdge: middle)
        _ = list.addAndMerge(anchorIndex: md.index, newEdge: thisRt)

        list.remove(index: this)
        list.remove(index: other)
        
        let verSegment = VersionSegment(vIndex: md, xSegment: middle.xSegment)
        scanStore.insert(segment: verSegment)

        return list.next(index: md.index)
    }
    
    private mutating func divideScanByThree(thisEdge: ShapeEdge, this: DualIndex, scanEdge: ShapeEdge, other: DualIndex) -> VersionedIndex {
        // segments collinear
        // scan.a < this.a < this.b < scan.b
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: thisEdge.xSegment.a, count: scanEdge.count)
        let merge = thisEdge.count.add(scanEdge.count)
        let scanRt = ShapeEdge.createAndValidate(a: thisEdge.xSegment.b, b: scanEdge.xSegment.b, count: scanEdge.count)
        
        let newVersion = list.update(index: this, count: merge)
        
        _ = list.addAndMerge(anchorIndex: other, newEdge: scanLt)
        _ = list.addAndMerge(anchorIndex: this, newEdge: scanRt)

        list.remove(index: other)
        
        let verIndex = VersionedIndex(version: newVersion, index: this)
        let verSegment = VersionSegment(vIndex: verIndex, xSegment: thisEdge.xSegment)
        scanStore.insert(segment: verSegment)
        
        return list.next(index: this)
    }
}


private extension XSegment {
    
    @inline(__always)
    func isNotSameLine(_ point: Point) -> Bool {
        let p = FixVec(point)
        let a = FixVec(self.a)
        let b = FixVec(self.b)
        return Triangle.isNotLine(p0: a, p1: b, p2: p)
    }
}

private extension ShapeEdge {
    static func createAndValidate(a: Point, b: Point, count: ShapeCount) -> ShapeEdge {
        if Point.xLineCompare(a: a, b: b) {
            ShapeEdge(xSegment: XSegment(a: a, b: b), count: count)
        } else {
            ShapeEdge(xSegment: XSegment(a: b, b: a), count: count.invert())
        }
    }
}
