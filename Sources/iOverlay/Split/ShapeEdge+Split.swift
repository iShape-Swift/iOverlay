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
        let isSmallRange = range.width < 128
#if DEBUG
        let isList = solver.strategy == .list || solver.strategy == .auto && (self.count < solver.treeListThreshold || isSmallRange)
#else
        let isList = solver.strategy == .list || solver.strategy == .auto && self.count < solver.treeListThreshold || isSmallRange
#endif
        
        let store = EdgeStore(edges: self, chunkStartLength: solver.chunkStartLength, chunkListMaxSize: solver.chunkListMaxSize)
        if isList {
            var solver = SplitSolver(store: store, scanStore: ScanSplitList(count: self.count))
            return solver.solve()
        } else {
            var solver = SplitSolver(store: store, scanStore: ScanSplitTree(range: range, count: self.count))
            return solver.solve()
        }
    }
}

private struct SplitSolver<S: ScanSplitStore> {
    
    private var scanStore: S
    private var store: EdgeStore
    
    init(store: EdgeStore, scanStore: S) {
        self.store = store
        self.scanStore = scanStore
    }
    
    mutating func solve() -> [Segment] {
        
        var needToFix = true
        
        while needToFix {
            needToFix = false
            
            var this = store.first(index: 0)

            while this.node != .empty {
                let thisEdge = store.edge(this)

                guard !thisEdge.count.isEmpty else {
                    this = store.removeAndNext(this)
                    continue
                }
                
                guard let scanResult = scanStore.intersectAndRemoveOther(this: thisEdge.xSegment) else {
                    scanStore.insert(segment: thisEdge.xSegment)
                    this = store.next(this)
                    continue
                }

                let other = store.find(xSegment: scanResult.other)
                
                guard other.node != .empty else {
                    continue
                }
                
                switch scanResult.cross {
                case .pureExact(let point):
                    this = self.pureExact(
                        point: point,
                        thisEdge: thisEdge,
                        other: other
                    )
                case .pureRound(let point):

                    this = self.pureRound(
                        point: point,
                        thisEdge: thisEdge,
                        other: other
                    )
                    needToFix = true
                    
                case .otherEndExact(let point):
                    
                    this = self.divideThisExact(
                        point: point,
                        thisEdge: thisEdge,
                        this: this,
                        other: other
                    )
                    
                case .otherEndRound(let point):
                    
                    this = self.divideThisRound(
                        point: point,
                        thisEdge: thisEdge,
                        this: this,
                        other: other
                    )
                    
                    needToFix = true
                    
                case .targetEndExact(let point):

                    this = self.divideScanExact(
                        point: point,
                        this: this,
                        thisEdge: thisEdge,
                        other: other
                    )

                case .targetEndRound(let point):
                    
                    this = self.divideScanRound(
                        point: point,
                        this: this,
                        thisEdge: thisEdge,
                        other: other
                    )
                    
                    needToFix = true
                    
                case .endOverlap:
                    // segments are collinear
                    // 2 situation are possible
                    // this.a inside scan(other)
                    // or
                    // scan.b inside this

                    let scan = store.get(other).xSegment

                    if thisEdge.xSegment.b == scan.b {
                        // this.a inside scan(other)

                        this = self.divideScanOverlap(
                            thisEdge: thisEdge,
                            other: other
                        )
                        
                        // scan.a < this.a
                        assert(scan.a < thisEdge.xSegment.a)
                    } else {
                        // scan.b inside this
                        
                        this = self.divideThisOverlap(
                            thisEdge: thisEdge,
                            this: this,
                            other: other
                        )
                        
                        // scan.b < this.b
                        assert(scan.b < thisEdge.xSegment.b)
                    }
                case .overlap:
                    // segments are collinear
                    // 2 situation are possible
                    // this if fully inside scan(other)
                    // or
                    // partly overlap each other
                    
                    let scan = store.get(other).xSegment
                    
                    if scan.b < thisEdge.xSegment.b {
                        // partly overlap
                        this = self.divideBothPartlyOverlap(
                            thisEdge: thisEdge,
                            other: other
                        )
                    } else {
                        assert(thisEdge.xSegment.b < scan.b)
                        // this inside scan
                        this = self.divideScanByThree(
                            thisEdge: thisEdge,
                            this: this,
                            other: other
                        )
                    }
                }
            } // while
            
            scanStore.clear()
        } // while
        
        return store.segments()
    }
    
    private mutating func pureExact(point p: Point, thisEdge: ShapeEdge, other: StoreIndex) -> StoreIndex {
        // classic middle intersection, no ends, overlaps etc
        let scanEdge = self.store.getAndRemove(other)
        self.store.remove(edge: thisEdge)
        
        let thisLt = ShapeEdge(xSegment: XSegment(a: thisEdge.xSegment.a, b: p), count: thisEdge.count)
        let thisRt = ShapeEdge(xSegment: XSegment(a: p, b: thisEdge.xSegment.b), count: thisEdge.count)
        
        assert(thisLt.xSegment.isLess(thisRt.xSegment))

        let scanLt = ShapeEdge(xSegment: XSegment(a: scanEdge.xSegment.a, b: p), count: scanEdge.count)
        let scanRt = ShapeEdge(xSegment: XSegment(a: p, b: scanEdge.xSegment.b), count: scanEdge.count)
        
        assert(scanLt.xSegment.isLess(scanRt.xSegment))
        
        _ = store.addAndMerge(edge: scanLt)
        _ = store.addAndMerge(edge: scanRt)
        
        _ = store.addAndMerge(edge: thisRt)
        let ltThis = store.addAndMerge(edge: thisLt)
        
        assert(thisLt.xSegment.a.x <= p.x)

        assert(ScanCrossSolver.isValid(scan: scanLt.xSegment, this: thisLt.xSegment))
        scanStore.insert(segment: scanLt.xSegment)
        
        assert(!ScanCrossSolver.isValid(scan: scanRt.xSegment, this: thisLt.xSegment))
        
        return ltThis
    }
    
    private mutating func pureRound(point p: Point, thisEdge: ShapeEdge, other: StoreIndex) -> StoreIndex {
        // classic middle intersection, no ends, overlaps etc
        
        let scanEdge = store.getAndRemove(other)
        store.remove(edge: thisEdge)
        
        let thisLt = ShapeEdge.createAndValidate(a: thisEdge.xSegment.a, b: p, count: thisEdge.count)
        let thisRt = ShapeEdge.createAndValidate(a: p, b: thisEdge.xSegment.b, count: thisEdge.count)
        
        assert(thisLt.xSegment.isLess(thisRt.xSegment))
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: p, count: scanEdge.count)
        let scanRt = ShapeEdge.createAndValidate(a: p, b: scanEdge.xSegment.b, count: scanEdge.count)
        
        assert(scanLt.xSegment.isLess(scanRt.xSegment))
        
        _ = store.addAndMerge(edge: scanLt)
        _ = store.addAndMerge(edge: scanRt)
        
        _ = store.addAndMerge(edge: thisRt)
        let ltThis = store.addAndMerge(edge: thisLt)
        
        assert(thisLt.xSegment.a.x <= p.x)
        
        if ScanCrossSolver.isValid(scan: scanLt.xSegment, this: thisLt.xSegment) {
            scanStore.insert(segment: scanLt.xSegment)
        }

        if ScanCrossSolver.isValid(scan: scanRt.xSegment, this: thisLt.xSegment) {
            scanStore.insert(segment: scanRt.xSegment)
        }
        
        return ltThis
    }
    
    private mutating func divideThisExact(point p: Point, thisEdge: ShapeEdge, this: StoreIndex, other: StoreIndex) -> StoreIndex {
        
        let scan = store.get(other).xSegment
        store.remove(index: this)
        
        let thisLt = ShapeEdge(xSegment: XSegment(a: thisEdge.xSegment.a, b: p), count: thisEdge.count)
        let thisRt = ShapeEdge(xSegment: XSegment(a: p, b: thisEdge.xSegment.b), count: thisEdge.count)
        
        assert(thisLt.xSegment.isLess(thisRt.xSegment))
        
        _ = store.addAndMerge(edge: thisRt)
        let ltThis = store.addAndMerge(edge: thisLt)
        
        if ScanCrossSolver.isValid(scan: scan, this: thisLt.xSegment) {
            scanStore.insert(segment: scan)
        }
        
        return ltThis
    }
    
    private mutating func divideThisRound(point p: Point, thisEdge: ShapeEdge, this: StoreIndex, other: StoreIndex) -> StoreIndex {

        let scan = store.get(other).xSegment
        store.remove(index: this)
        
        let thisLt = ShapeEdge.createAndValidate(a: thisEdge.xSegment.a, b: p, count: thisEdge.count)
        let thisRt = ShapeEdge.createAndValidate(a: p, b: thisEdge.xSegment.b, count: thisEdge.count)
        
        assert(thisLt.xSegment.isLess(thisRt.xSegment))
        
        _ = store.addAndMerge(edge: thisRt)
        let ltThis = store.addAndMerge(edge: thisLt)

        
        if ScanCrossSolver.isValid(scan: scan, this: thisLt.xSegment) {
            scanStore.insert(segment: scan)
        }
        
        return ltThis
    }
    
    private mutating func divideScanExact(point p: Point, this: StoreIndex, thisEdge: ShapeEdge, other: StoreIndex) -> StoreIndex {
        // this segment-end divide scan(other) segment into 2 parts
        
        let scanEdge = store.getAndRemove(other)
        
        let scanLt = ShapeEdge(xSegment: XSegment(a: scanEdge.xSegment.a, b: p), count: scanEdge.count)
        let scanRt = ShapeEdge(xSegment: XSegment(a: p, b: scanEdge.xSegment.b), count: scanEdge.count)
        
        assert(scanLt.xSegment.isLess(scanRt.xSegment))
        
        _ = store.addAndMerge(edge: scanLt)
        _ = store.addAndMerge(edge: scanRt)

        if thisEdge.xSegment.a.x < p.x {
            // this < p
            scanStore.insert(segment: scanLt.xSegment)
        } else if scanRt.xSegment.isLess(thisEdge.xSegment) {
            // scanRt < this
            scanStore.insert(segment: scanRt.xSegment)
        }
        
        return store.findEqualOrNext(root: this.root, xSegment: thisEdge.xSegment)
    }
    
    private mutating func divideScanRound(point p: Point, this: StoreIndex, thisEdge: ShapeEdge, other: StoreIndex) -> StoreIndex {
        // this segment-end divide scan(other) segment into 2 parts
        
        let scanEdge = store.getAndRemove(other)
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: p, count: scanEdge.count)
        let scanRt = ShapeEdge.createAndValidate(a: p, b: scanEdge.xSegment.b, count: scanEdge.count)
        
        assert(scanLt.xSegment.isLess(scanRt.xSegment))
        
        _ = store.addAndMerge(edge: scanLt)
        _ = store.addAndMerge(edge: scanRt)
        
        if thisEdge.xSegment.a.x < p.x {
            // this < p
            scanStore.insert(segment: scanLt.xSegment)
        } else if scanRt.xSegment.isLess(thisEdge.xSegment) {
            // scanRt < this
            scanStore.insert(segment: scanRt.xSegment)
        }
        
        return store.findEqualOrNext(root: this.root, xSegment: thisEdge.xSegment)
    }
    
    private mutating func divideScanOverlap(thisEdge: ShapeEdge, other: StoreIndex) -> StoreIndex {
        // segments collinear
        // this.b == scan.b and scan.a < this.a < scan.b
        
        let scanEdge = store.getAndRemove(other)
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: thisEdge.xSegment.a, count: scanEdge.count)
        
        _ = store.addAndMerge(edge: scanLt)
        let newThis = store.addAndMerge(edge: ShapeEdge(xSegment: thisEdge.xSegment, count: scanEdge.count)) // add scanEdge to this

        if newThis.node == .empty {
            return store.findEqualOrNext(root: newThis.root, xSegment: thisEdge.xSegment)
        } else {
            return store.next(newThis)
        }
    }
    
    private mutating func divideThisOverlap(thisEdge: ShapeEdge, this: StoreIndex, other: StoreIndex) -> StoreIndex {
        // segments collinear
        // this.a == scan.a and this.a < scan.b < this.b
        
        let scanEdge = store.get(other)
        
        let merge = thisEdge.count.add(scanEdge.count)
        let thisRt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.b, b: thisEdge.xSegment.b, count: thisEdge.count)
        
        store.update(other, count: merge)
        _ = store.addAndMerge(edge: thisRt)
        
        store.remove(index: this)
        
        scanStore.insert(segment: scanEdge.xSegment)

        let newOther = store.find(xSegment: scanEdge.xSegment)
        
        return store.next(newOther)
    }
    
    private mutating func divideBothPartlyOverlap(thisEdge: ShapeEdge, other: StoreIndex) -> StoreIndex {
        // segments collinear
        // scan.a < this.a < scan.b < this.b

        let scanEdge = store.getAndRemove(other)
        store.remove(edge: thisEdge)
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: thisEdge.xSegment.a, count: scanEdge.count)
        let middle = ShapeEdge.createAndValidate(a: thisEdge.xSegment.a, b: scanEdge.xSegment.b, count: scanEdge.count.add(thisEdge.count))
        let thisRt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.b, b: thisEdge.xSegment.b, count: thisEdge.count)
        
        _ = store.addAndMerge(edge: scanLt)
        _ = store.addAndMerge(edge: thisRt)
        let md = store.addAndMerge(edge: middle)

        scanStore.insert(segment: middle.xSegment)
        
        return store.next(md)
    }
    
    private mutating func divideScanByThree(thisEdge: ShapeEdge, this: StoreIndex, other: StoreIndex) -> StoreIndex {
        // segments collinear
        // scan.a < this.a < this.b < scan.b
        
        let scanEdge = store.get(other)
        
        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: thisEdge.xSegment.a, count: scanEdge.count)
        let merge = thisEdge.count.add(scanEdge.count)
        let scanRt = ShapeEdge.createAndValidate(a: thisEdge.xSegment.b, b: scanEdge.xSegment.b, count: scanEdge.count)
        
        store.update(this, count: merge)
        store.remove(index: other)
        
        _ = store.addAndMerge(edge: scanLt)
        _ = store.addAndMerge(edge: scanRt)
        
        scanStore.insert(segment: thisEdge.xSegment)

        let newThis = store.find(xSegment: thisEdge.xSegment)
        
        return store.next(newThis)
    }
}

private extension ShapeEdge {
    static func createAndValidate(a: Point, b: Point, count: ShapeCount) -> ShapeEdge {
        if a < b {
            ShapeEdge(xSegment: XSegment(a: a, b: b), count: count)
        } else {
            ShapeEdge(xSegment: XSegment(a: b, b: a), count: count.invert())
        }
    }
}
