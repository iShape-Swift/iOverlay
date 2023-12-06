//
//  ShapeEdge+Split.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iFixFloat
import iShape

extension Array where Element == ShapeEdge {
    
    mutating func split() {
        // at this moment array is sorted
        
        var list = EdgeRangeList(edges: self)
        
        var scanList = ScanList(edges: self)
        
        var needToFix = true
        
        while needToFix {
            scanList.clear()
            needToFix = false
            
            var eIndex = list.first()

            while eIndex.isNotNil {
                let thisEdge = list.edge(index: eIndex.index)

                if thisEdge.count.isEven {
                    eIndex = list.removeAndNext(index: eIndex.index)

                    continue
                }
                
                let vRange = thisEdge.verticalRange
                
                let isCompleted = scanList.iterateAllInRange(range: vRange) { vIndex in
                    guard let scanEdge = list.validateEdge(vIndex: vIndex), !scanEdge.isLess(thisEdge) else {
                        return .removeAndNext
                    }

                    guard let cross = thisEdge.edge.cross(scanEdge.edge) else {
                        return .next
                    }

                    switch cross.type {
                    case .pure:
                        // if the two segments intersect at a point that isn't an end point of either segment...
                        
                        let x = cross.point

                        // divide both segments
                        
                        let thisLt = ShapeEdge(a: thisEdge.a, b: x, count: thisEdge.count)
                        let thisRt = ShapeEdge(a: x, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(thisLt.isLess(thisRt))
                        
                        let scanLt = ShapeEdge(a: scanEdge.a, b: x, count: scanEdge.count)
                        let scanRt = ShapeEdge(a: x, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scanLt.isLess(scanRt))
                        
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
                        
                        return .addAndStop(.init(id: newScanLeft, range: scanLt.verticalRange))
                    case .end_b:
                        // scan edge end divide this edge into 2 parts
                        
                        let x = cross.point
                        
                        // divide this edge
                        
                        let thisLt = ShapeEdge(a: thisEdge.a, b: x, count: thisEdge.count)
                        let thisRt = ShapeEdge(a: x, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(thisLt.isLess(thisRt))
                        
                        _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisRt)
                        let newThisLeft = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisLt)

                        list.remove(index: eIndex.index)
                        
                        eIndex = newThisLeft
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend
                        
                        return .stop
                    case .overlay_b:
                        // split this into 3 segments

                        let this0 = ShapeEdge(a: thisEdge.a, b: scanEdge.a, count: thisEdge.count)
                        let this1 = ShapeEdge(a: scanEdge.a, b: scanEdge.b, count: thisEdge.count)
                        let this2 = ShapeEdge(a: scanEdge.b, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(this0.isLess(this1))
                        assert(this1.isLess(this2))
                        
                        _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: this1)
                        _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: this2)
                        let newThis0 = list.addAndMerge(anchorIndex: eIndex.index, newEdge: this0)
                        
                        list.remove(index: eIndex.index)
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(scanEdge.a) || thisEdge.isNotSameLine(scanEdge.b)
                        needToFix = needToFix || isBend
                        
                        eIndex = newThis0
                        
                        return .stop
                    case .end_a:
                        // this edge end divide scan edge into 2 parts
                        
                        let x = cross.point

                        // divide scan edge
                        
                        let scanLt = ShapeEdge(a: scanEdge.a, b: x, count: scanEdge.count)
                        let scanRt = ShapeEdge(a: x, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scanLt.isLess(scanRt))
                        
                        let newScanLeft = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanLt)
                        _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanRt)

                        list.remove(index: vIndex.index)

                        // new point must be exactly on the same line
                        let isBend = scanEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend
                        
                        // do not update eIndex
                        
                        return .addAndStop(.init(id: newScanLeft, range: scanLt.verticalRange))
                    case .overlay_a:
                        // split scan into 3 segments
                        
                        let scan0 = ShapeEdge(a: scanEdge.a, b: thisEdge.a, count: scanEdge.count)
                        let scan1 = ShapeEdge(a: thisEdge.a, b: thisEdge.b, count: scanEdge.count)
                        let scan2 = ShapeEdge(a: thisEdge.b, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scan0.isLess(scan1))
                        assert(scan1.isLess(scan2))
                        
                        let newScan0 = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scan0)
                        _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scan1)
                        _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scan2)

                        list.remove(index: vIndex.index)

                        let isBend = scanEdge.isNotSameLine(thisEdge.a) || scanEdge.isNotSameLine(thisEdge.b)
                        needToFix = needToFix || isBend
                        
                        // do not update eIndex
                        
                        return .addAndStop(.init(id: newScan0, range: scan0.verticalRange))
                    case .penetrate:
                        // penetrate each other
                        
                        let xThis = cross.point
                        let xScan = cross.second

                        // divide both segments
                        
                        let thisLt = ShapeEdge(a: thisEdge.a, b: xThis, count: thisEdge.count)
                        let thisRt = ShapeEdge(a: xThis, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(thisLt.isLess(thisRt))
                        
                        let scanLt = ShapeEdge(a: scanEdge.a, b: xScan, count: scanEdge.count)
                        let scanRt = ShapeEdge(a: xScan, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scanLt.isLess(scanRt))
                        
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
                        
                        return .addAndStop(.init(id: newScanLeft, range: scanLt.verticalRange))
                    }
                }

                if isCompleted {
                    scanList.insert(segment: LineSegment<VersionedIndex>(id: eIndex, range: vRange))
                    eIndex = list.next(index: eIndex.index)
                }
            } // while
        } // while
        
        self = list.edges()
    }
}


private extension ShapeEdge {

    @inline(__always)
    func isNotSameLine(_ point: FixVec) -> Bool {
        Triangle.isNotLine(p0: a, p1: b, p2: point)
    }
}
