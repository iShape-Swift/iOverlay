//
//  ShapeEdge+Split.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iFixFloat
import iShape

extension Array where Element == ShapeEdge {
    
    func split<S: ScanSplitStore>(scanList: S) -> [Segment] {
        var scanList = scanList

        var list = SplitRangeList(edges: self)
        
        var needToFix = true
        
        while needToFix {
            needToFix = false
            
            var eIndex = list.first()

            while eIndex.isNotNil {
                let thisEdge = list.edge(index: eIndex.index)

                guard !thisEdge.count.isEmpty else {
                    eIndex = list.removeAndNext(index: eIndex.index)
                    continue
                }
                
                let scanPos = thisEdge.xSegment.a.x
                guard let crossSegment = scanList.intersect(this: thisEdge.xSegment, scanPos: scanPos) else {
                    scanList.insert(segment: VersionSegment(vIndex: eIndex, xSegment: thisEdge.xSegment))
                    eIndex = list.next(index: eIndex.index)
                    continue
                }

                let vIndex = crossSegment.index
                
                guard let scanEdge = list.validateEdge(vIndex: vIndex) else {
                    eIndex = list.next(index: eIndex.index)
                    continue
                }
                        
                switch crossSegment.cross.type {
                case .pure:
                    // if the two segments intersect at a point that isn't an end point of either segment...
                    
                    let x = crossSegment.cross.point
                    
                    // divide both segments
                    
                    let thisLt = ShapeEdge.createAndValidate(a: thisEdge.xSegment.a, b: x, count: thisEdge.count)
                    let thisRt = ShapeEdge.createAndValidate(a: x, b: thisEdge.xSegment.b, count: thisEdge.count)
                    
                    assert(thisLt.xSegment.isLess(thisRt.xSegment))
                    
                    let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: x, count: scanEdge.count)
                    let scanRt = ShapeEdge.createAndValidate(a: x, b: scanEdge.xSegment.b, count: scanEdge.count)
                    
                    assert(scanLt.xSegment.isLess(scanRt.xSegment))
                    
                    let newThisLeft = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisLt)
                    _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisRt)
                    
                    let newScanLeft = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanLt)
                    _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanRt)
                    
                    list.remove(index: eIndex.index)
                    list.remove(index: vIndex.index)
                    
                    // new point must be exactly on the same line
                    let isBend = thisEdge.isNotSameLine(x) || scanEdge.isNotSameLine(x)
                    needToFix = needToFix || isBend
                    
                    eIndex = newThisLeft
                    scanList.insert(segment: VersionSegment(vIndex: newScanLeft, xSegment: scanLt.xSegment))
                case .end_b:
                    // scan edge end divide this edge into 2 parts
                    
                    let x = crossSegment.cross.point
                    
                    // divide this edge
                    
                    let thisLt = ShapeEdge.createAndValidate(a: thisEdge.xSegment.a, b: x, count: thisEdge.count)
                    let thisRt = ShapeEdge.createAndValidate(a: x, b: thisEdge.xSegment.b, count: thisEdge.count)
                    
                    assert(thisLt.xSegment.isLess(thisRt.xSegment))
                    
                    _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisRt)
                    let newThisLeft = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisLt)
                    
                    list.remove(index: eIndex.index)
                    
                    eIndex = newThisLeft
                    
                    // new point must be exactly on the same line
                    let isBend = thisEdge.isNotSameLine(x)
                    needToFix = needToFix || isBend
                case .overlay_b:
                    // split this into 3 segments
                    
                    let this0 = ShapeEdge(a: thisEdge.xSegment.a, b: scanEdge.xSegment.a, count: thisEdge.count)
                    let this1 = ShapeEdge(a: scanEdge.xSegment.a, b: scanEdge.xSegment.b, count: thisEdge.count)
                    let this2 = ShapeEdge(a: scanEdge.xSegment.b, b: thisEdge.xSegment.b, count: thisEdge.count)
                    
                    assert(this0.xSegment.isLess(this1.xSegment))
                    assert(this1.xSegment.isLess(this2.xSegment))
                    
                    _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: this1)
                    _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: this2)
                    let newThis0 = list.addAndMerge(anchorIndex: eIndex.index, newEdge: this0)
                    
                    list.remove(index: eIndex.index)
                    
                    // new point must be exactly on the same line
                    let isBend = thisEdge.isNotSameLine(scanEdge.xSegment.a) || thisEdge.isNotSameLine(scanEdge.xSegment.b)
                    needToFix = needToFix || isBend
                    
                    eIndex = newThis0
                case .end_a:
                    // this edge end divide scan edge into 2 parts
                    
                    let x = crossSegment.cross.point
                    
                    // divide scan edge
                    
                    let scanLt = ShapeEdge.createAndValidate(a: scanEdge.xSegment.a, b: x, count: scanEdge.count)
                    let scanRt = ShapeEdge.createAndValidate(a: x, b: scanEdge.xSegment.b, count: scanEdge.count)
                    
                    assert(scanLt.xSegment.isLess(scanRt.xSegment))
                    
                    let newScanLeft = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanLt)
                    _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanRt)
                    
                    list.remove(index: vIndex.index)
                    
                    // new point must be exactly on the same line
                    let isBend = scanEdge.isNotSameLine(x)
                    needToFix = needToFix || isBend
                    
                    // do not update eIndex
                    scanList.insert(segment: VersionSegment(vIndex: newScanLeft, xSegment: scanLt.xSegment))
                case .overlay_a:
                    // split scan into 3 segments
                    
                    let scan0 = ShapeEdge(a: scanEdge.xSegment.a, b: thisEdge.xSegment.a, count: scanEdge.count)
                    let scan1 = ShapeEdge(a: thisEdge.xSegment.a, b: thisEdge.xSegment.b, count: scanEdge.count)
                    let scan2 = ShapeEdge(a: thisEdge.xSegment.b, b: scanEdge.xSegment.b, count: scanEdge.count)
                    
                    assert(scan0.xSegment.isLess(scan1.xSegment))
                    assert(scan1.xSegment.isLess(scan2.xSegment))
                    
                    let newScan0 = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scan0)
                    _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scan1)
                    _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scan2)
                    
                    list.remove(index: vIndex.index)
                    
                    let isBend = scanEdge.isNotSameLine(thisEdge.xSegment.a) || scanEdge.isNotSameLine(thisEdge.xSegment.b)
                    needToFix = needToFix || isBend
                    
                    // do not update eIndex
                    scanList.insert(segment: VersionSegment(vIndex: newScan0, xSegment: scan0.xSegment))
                case .penetrate:
                    // penetrate each other
                    
                    let xThis = crossSegment.cross.point
                    let xScan = crossSegment.cross.second
                    
                    // divide both segments
                    
                    let thisLt = ShapeEdge(a: thisEdge.xSegment.a, b: xThis, count: thisEdge.count)
                    let thisRt = ShapeEdge(a: xThis, b: thisEdge.xSegment.b, count: thisEdge.count)
                    
                    assert(thisLt.xSegment.isLess(thisRt.xSegment))
                    
                    let scanLt = ShapeEdge(a: scanEdge.xSegment.a, b: xScan, count: scanEdge.count)
                    let scanRt = ShapeEdge(a: xScan, b: scanEdge.xSegment.b, count: scanEdge.count)
                    
                    assert(scanLt.xSegment.isLess(scanRt.xSegment))
                    
                    let newScanLeft = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanLt)
                    _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanRt)
                    
                    _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisRt)
                    let newThisLeft = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisLt)
                    
                    list.remove(index: eIndex.index)
                    list.remove(index: vIndex.index)
                    
                    // new point must be exactly on the same line
                    let isBend = thisEdge.isNotSameLine(xThis) || scanEdge.isNotSameLine(xScan)
                    needToFix = needToFix || isBend
                    
                    eIndex = newThisLeft
                    
                    scanList.insert(segment: VersionSegment(vIndex: newScanLeft, xSegment: scanLt.xSegment))
                }
            } // while
            
            scanList.clear()
        } // while
        
        return list.segments()
    }
}


private extension ShapeEdge {
    
    @inline(__always)
    func isNotSameLine(_ point: Point) -> Bool {
        let p = FixVec(point)
        let a = FixVec(self.xSegment.a)
        let b = FixVec(self.xSegment.b)
        return Triangle.isNotLine(p0: a, p1: b, p2: p)
    }

    static func createAndValidate(a: Point, b: Point, count: ShapeCount) -> ShapeEdge {
        if Point.xLineCompare(a: a, b: b) {
            ShapeEdge(min: a, max: b, count: count)
        } else {
            ShapeEdge(min: b, max: a, count: count.invert())
        }
    }
}
