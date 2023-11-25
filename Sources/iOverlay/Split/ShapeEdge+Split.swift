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
        
        let capacity = 3 * Int(Double(self.count).squareRoot())
        
        var scanList = ScanList(capacity: capacity)
        
        var needToFix = true
        
        while needToFix {
            scanList.clear()
            needToFix = false
            
            var eIndex = list.first()

        mainLoop:
            while eIndex.isValid {
                let thisEdge = list.edge(index: eIndex)

                if thisEdge.count.isEven {
                    eIndex = list.removeAndNext(index: eIndex)

                    continue
                }
                
                let scanPos = thisEdge.aBitPack
                
                var scanIndex = 0
                
                // Try to intersect the current segment with all the segments in the scan list.
                while scanIndex < scanList.count {
                    let sIndex = scanList[scanIndex]
                    let scanEdge = list.edge(index: sIndex)
                    
                    // scan list can contain not valid edges
                    if scanEdge.bBitPack <= scanPos ||  // edge is behind scan line
                        thisEdge.isLess(scanEdge) ||    // edge is forward then this, we will add it again later
                        scanEdge.count.isEven           // overlaps count is even
                    {
                        scanList.removeBySwap(index: scanIndex)
                        continue
                    }

                    guard let cross = thisEdge.cross(scanEdge) else {
                        scanIndex += 1
                        continue
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
                        
                        let newThisLeft = list.addAndMerge(anchorIndex: eIndex, newEdge: thisLt)
                        _ = list.addAndMerge(anchorIndex: eIndex, newEdge: thisRt)

                        let newScanLeft = list.addAndMerge(anchorIndex: sIndex, newEdge: scanLt)
                        _ = list.addAndMerge(anchorIndex: sIndex, newEdge: scanRt)

                        list.remove(index: eIndex)
                        list.remove(index: sIndex)

                        scanList.add(index: newScanLeft)

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x) || scanEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend
                        
                        eIndex = newThisLeft
                        
                        continue mainLoop
                    case .end_b:
                        // scan edge end divide this edge into 2 parts
                        
                        let x = cross.point
                        
                        // divide this edge
                        
                        let thisLt = ShapeEdge(a: thisEdge.a, b: x, count: thisEdge.count)
                        let thisRt = ShapeEdge(a: x, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(thisLt.isLess(thisRt))
                        
                        _ = list.addAndMerge(anchorIndex: eIndex, newEdge: thisRt)
                        let newThisLeft = list.addAndMerge(anchorIndex: eIndex, newEdge: thisLt)

                        list.remove(index: eIndex)
                        
                        eIndex = newThisLeft
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend
                        
                        continue mainLoop
                    case .overlay_b:
                        // split this into 3 segments

                        let this0 = ShapeEdge(a: thisEdge.a, b: scanEdge.a, count: thisEdge.count)
                        let this1 = ShapeEdge(a: scanEdge.a, b: scanEdge.b, count: thisEdge.count)
                        let this2 = ShapeEdge(a: scanEdge.b, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(this0.isLess(this1))
                        assert(this1.isLess(this2))
                        
                        _ = list.addAndMerge(anchorIndex: eIndex, newEdge: this1)
                        _ = list.addAndMerge(anchorIndex: eIndex, newEdge: this2)
                        let newThis0 = list.addAndMerge(anchorIndex: eIndex, newEdge: this0)
                        
                        list.remove(index: eIndex)
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(scanEdge.a) || thisEdge.isNotSameLine(scanEdge.b)
                        needToFix = needToFix || isBend
                        
                        eIndex = newThis0
                        
                        continue mainLoop
                    case .end_a:
                        // this edge end divide scan edge into 2 parts
                        
                        let x = cross.point

                        // divide scan edge
                        
                        let scanLt = ShapeEdge(a: scanEdge.a, b: x, count: scanEdge.count)
                        let scanRt = ShapeEdge(a: x, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scanLt.isLess(scanRt))
                        
                        let newScanLeft = list.addAndMerge(anchorIndex: sIndex, newEdge: scanLt)
                        _ = list.addAndMerge(anchorIndex: sIndex, newEdge: scanRt)

                        list.remove(index: sIndex)

                        scanList.add(index: newScanLeft)

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
                        
                        assert(scan0.isLess(scan1))
                        assert(scan1.isLess(scan2))
                        
                        let newScan0 = list.addAndMerge(anchorIndex: sIndex, newEdge: scan0)
                        _ = list.addAndMerge(anchorIndex: sIndex, newEdge: scan1)
                        _ = list.addAndMerge(anchorIndex: sIndex, newEdge: scan2)

                        list.remove(index: sIndex)

                        scanList.add(index: newScan0)

                        let isBend = scanEdge.isNotSameLine(thisEdge.a) || scanEdge.isNotSameLine(thisEdge.b)
                        needToFix = needToFix || isBend
                        
                        // do not update eIndex

                        continue mainLoop
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
                        
                        let newScanLeft = list.addAndMerge(anchorIndex: sIndex, newEdge: scanLt)
                        _ = list.addAndMerge(anchorIndex: sIndex, newEdge: scanRt)
                        
                        _ = list.addAndMerge(anchorIndex: eIndex, newEdge: thisRt)
                        let newThisLeft = list.addAndMerge(anchorIndex: eIndex, newEdge: thisLt)

                        list.remove(index: eIndex)
                        list.remove(index: sIndex)

                        scanList.add(index: newScanLeft)

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(xThis) || scanEdge.isNotSameLine(xScan)
                        needToFix = needToFix || isBend
                        
                        eIndex = newThisLeft
                        
                        continue mainLoop
                    }
                } // for scanList
                
                // no intersections, add to scan
                scanList.unsafeAdd(index: eIndex)
                
                eIndex = list.next(index: eIndex)
                
            } // while mainLoop
        }
        
        self = list.edges()
    }
}


private extension ShapeEdge {

    func cross(_ edge: ShapeEdge) -> EdgeCross? {
        if edge.maxY < minY || edge.minY > maxY {
            return nil
        } else {
            return self.edge.cross(edge.edge)
        }
    }

    @inline(__always)
    func isNotSameLine(_ point: FixVec) -> Bool {
        Triangle.isNotLine(p0: a, p1: b, p2: point)
    }
}
