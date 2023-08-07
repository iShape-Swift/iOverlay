//
//  File.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iFixFloat
import iShape

extension Array where Element == ShapeEdge {
    
    mutating func split2() {
        var list = EdgeList(edges: self)
        
        var scanList = SList(count: list.count)
        
        var needToFix = true
        
        while needToFix {
            scanList.clear()
            needToFix = false
            
            var eIndex = list.first

        mainLoop:
            while eIndex >= 0 {
                let eNode = list.list[eIndex]
                let thisEdge = eNode.edge
                
                let scanPos = thisEdge.a.bitPack
                
                var sIndex = scanList.first
                
                // Try to intersect the current segment with all the segments in the scan list.
                while sIndex != -1 {
                    let scanEdge = list[sIndex]
                    
                    assert(scanEdge.a != scanEdge.b)
                    
                    if scanEdge.b.bitPack <= scanPos {
                        sIndex = scanList.removeAndGetNext(index: sIndex)
                        continue
                    }

                    let cross = thisEdge.cross(scanEdge)
                    
                    switch cross.type {
                    case .not_cross:
                        break
                    case .pure:
                        // If the two segments intersect at a point that isn't an end point of either segment...
                        
                        let x = cross.point

                        // devide both segments
                        
                        let thisLt = ShapeEdge(a: thisEdge.a, b: x, count: thisEdge.count)
                        let thisRt = ShapeEdge(a: x, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(thisLt.isLess(thisRt))
                        
                        let scanLt = ShapeEdge(a: scanEdge.a, b: x, count: scanEdge.count)
                        let scanRt = ShapeEdge(a: x, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scanLt.isLess(scanRt))
                        
                        _ = list.addAndMerge(anchorIndex: eIndex, edge: thisRt)
                        let newIndex = list.addAndMerge(anchorIndex: eIndex, edge: thisLt)
                        
                        let scanLeftIndex = list.addAndMerge(anchorIndex: sIndex, edge: scanLt)
                        _ = list.addAndMerge(anchorIndex: sIndex, edge: scanRt)
                        
                        list.remove(index: eIndex)
                        list.remove(index: sIndex)
                        
                        scanList.remove(index: sIndex)
                        scanList.add(index: scanLeftIndex)
                        scanList.removeAllLess(edge: thisLt, list: list)

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x) || scanEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend
                        
                        eIndex = newIndex

                        assert(list.edges().isAsscending())
                        
                        continue mainLoop
                    case .end_b:
                        // if the intersection point is at the end of the current edge...
                        
                        let x = cross.point
                        
                        // devide this edge
                        
                        let thisLt = ShapeEdge(a: thisEdge.a, b: x, count: thisEdge.count)
                        let thisRt = ShapeEdge(a: x, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(thisLt.isLess(thisRt))
                        
                        _ = list.addAndMerge(anchorIndex: eIndex, edge: thisRt)
                        let newIndex = list.addAndMerge(anchorIndex: eIndex, edge: thisLt)
                        
                        list.remove(index: eIndex)
                        
                        scanList.removeAllLess(edge: thisLt, list: list)
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend
                        
                        eIndex = newIndex
                        
                        assert(list.edges().isAsscending())
                        
                        continue mainLoop
                    case .overlay_b:
                        // split this into 3 segments

                        let this0 = ShapeEdge(a: thisEdge.a, b: scanEdge.a, count: thisEdge.count)
                        let this1 = ShapeEdge(a: scanEdge.a, b: scanEdge.b, count: thisEdge.count)
                        let this2 = ShapeEdge(a: scanEdge.b, b: thisEdge.b, count: thisEdge.count)
                        
                        _ = list.addAndMerge(anchorIndex: eIndex, edge: this1)
                        _ = list.addAndMerge(anchorIndex: eIndex, edge: this2)
                        let newIndex = list.addAndMerge(anchorIndex: eIndex, edge: this0)
                        
                        list.remove(index: eIndex)
                        
                        scanList.removeAllLess(edge: this0, list: list)
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(scanEdge.a) || thisEdge.isNotSameLine(scanEdge.b)
                        needToFix = needToFix || isBend
                        
                        eIndex = newIndex
                        
                        assert(list.edges().isAsscending())
                        
                        continue mainLoop
                    case .end_a:
                        // this edge end devide scan edge into 2 parts
                        
                        let x = cross.point

                        // devide scan edge
                        
                        let scanLt = ShapeEdge(a: scanEdge.a, b: x, count: scanEdge.count)
                        let scanRt = ShapeEdge(a: x, b: scanEdge.b, count: scanEdge.count)
                        
                        let es0 = list.edges()
                        assert(es0.isAsscending())
                        
                        let scanLeftIndex = list.addAndMerge(anchorIndex: sIndex, edge: scanLt)
                        _ = list.addAndMerge(anchorIndex: sIndex, edge: scanRt)

                        list.remove(index: sIndex)

                        scanList.remove(index: sIndex)
                        scanList.add(index: scanLeftIndex)
                        scanList.removeAllLess(edge: thisEdge, list: list)

                        let es1 = list.edges()
                        assert(es1.isAsscending())
                        
                        // new point must be exactly on the same line
                        let isBend = scanEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend
                        
                        // do not update eIndex

                        continue mainLoop
                    case .overlay_a:
                        // split scan into 3 segments
                        
                        let scan0 = ShapeEdge(a: scanEdge.a, b: thisEdge.a, count: scanEdge.count)
                        let scan1 = ShapeEdge(a: thisEdge.a, b: thisEdge.b, count: scanEdge.count)
                        let scan2 = ShapeEdge(a: thisEdge.b, b: scanEdge.b, count: scanEdge.count)
                        
                        let scanLeftIndex = list.addAndMerge(anchorIndex: sIndex, edge: scan0)
                        _ = list.addAndMerge(anchorIndex: sIndex, edge: scan1)
                        _ = list.addAndMerge(anchorIndex: sIndex, edge: scan2)

                        list.remove(index: sIndex)
                        
                        scanList.remove(index: sIndex)
                        scanList.add(index: scanLeftIndex)
                        scanList.removeAllLess(edge: thisEdge, list: list)

                        let isBend = scanEdge.isNotSameLine(thisEdge.a) || scanEdge.isNotSameLine(thisEdge.b)
                        needToFix = needToFix || isBend
                        
                        // do not update eIndex
                        
                        assert(list.edges().isAsscending())
                        
                        continue mainLoop
                    case .penetrate:
                        // penetrate each other
                        
                        let xThis = cross.point
                        let xScan = cross.second

                        // devide both segments
                        
                        let thisLt = ShapeEdge(a: thisEdge.a, b: xThis, count: thisEdge.count)
                        let thisRt = ShapeEdge(a: xThis, b: thisEdge.b, count: thisEdge.count)
                        
                        let scanLt = ShapeEdge(a: scanEdge.a, b: xScan, count: thisEdge.count)
                        let scanRt = ShapeEdge(a: xScan, b: scanEdge.b, count: thisEdge.count)
                        
                        let scanLeftIndex = list.addAndMerge(anchorIndex: sIndex, edge: scanLt)
                        _ = list.addAndMerge(anchorIndex: sIndex, edge: scanRt)
                        
                        _ = list.addAndMerge(anchorIndex: eIndex, edge: thisRt)
                        let newIndex = list.addAndMerge(anchorIndex: eIndex, edge: thisLt)

                        list.remove(index: eIndex)
                        list.remove(index: sIndex)
                        
                        scanList.remove(index: sIndex)
                        scanList.add(index: scanLeftIndex)
                        scanList.removeAllLess(edge: thisEdge, list: list)

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(xThis) || scanEdge.isNotSameLine(xScan)
                        needToFix = needToFix || isBend
                        
                        eIndex = newIndex
                        
                        assert(list.edges().isAsscending())
                        
                        continue mainLoop
                    }
                    
                    sIndex = scanList.next(index: sIndex)
                    
                } // for scanList
                
                // no intersections, add to scan
                scanList.add(index: eIndex)
                
                eIndex = eNode.next
                
            } // while mainLoop
        }
        
        
        self = list.edges()
    }
   
}


private extension ShapeEdge {

    func cross(_ edge: ShapeEdge) -> EdgeCross {
        guard edge.minY <= maxY && edge.maxY >= minY else {
            return EdgeCross.notCross
        }

        return self.edge.cross(edge.edge)
    }

    func isNotSameLine(_ point: FixVec) -> Bool {
        Triangle.isNotLine(p0: a, p1: b, p2: point)
    }
}
