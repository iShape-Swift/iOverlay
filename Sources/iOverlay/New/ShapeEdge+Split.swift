//
//  ShapeEdge+Split.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

//import iFixFloat
//import iShape
//
//extension Array where Element == ShapeEdge {
//    
//    mutating func split() {
//        var scanList = ScanList()
//        
//        var needToFix = true
//        
//        var ee = 0
//        
//        while needToFix {
//            scanList.clear()
//            needToFix = false
//            
//            var eIndex = 0
//
//        mainLoop:
//            while eIndex < self.count {
//                let thisEdge = self[eIndex]
//                
//                let scanPos = thisEdge.a.bitPack
//
//                scanList.removeAllEndingBeforePosition(scanPos)
//                
//                // Try to intersect the current segment with all the segments in the scan list.
//                for scanIndex in 0..<scanList.edges.count {
//                    
//                    let eScan = scanList.edges[scanIndex]
//                    let cross = thisEdge.cross(eScan)
//                    
//                    switch cross.type {
//                    case .not_cross:
//                        break
//                    case .pure:
//                        // If the two segments intersect at a point that isn't an end point of either segment...
//                        
//                        let x = cross.point
//                        
//                        let sIndex = self.findEdgeIndex(eScan)
//                        let scanEdge = self[sIndex]
//                        
//                        if eIndex < sIndex {
//                            self.remove(at: sIndex)
//                            self.remove(at: eIndex)
//                        } else {
//                            self.remove(at: eIndex)
//                            self.remove(at: sIndex)
//                        }
//                        
//                        // devide both segments
//                        
//                        let thisLt = ShapeEdge(a: thisEdge.a, b: x, count: thisEdge.count)
//                        let thisRt = ShapeEdge(a: x, b: thisEdge.b, count: thisEdge.count)
//                        
//                        let scanLt = ShapeEdge(a: scanEdge.a, b: x, count: scanEdge.count)
//                        let scanRt = ShapeEdge(a: x, b: scanEdge.b, count: scanEdge.count)
//                        
//                        _ = self.addAndMerge(scanLt)
//                        _ = self.addAndMerge(scanRt)
//                        _ = self.addAndMerge(thisRt)
//                        eIndex = self.addAndMerge(thisLt)
//
//                        // new point must be exactly on the same line
//                        let isBend = thisEdge.isNotSameLine(x) || scanEdge.isNotSameLine(x)
//                        
//                        needToFix = needToFix || isBend
//                        
//                        // replace current with left part
//                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt.edge)
//                        scanList.removeAllLater(edge: thisLt.edge)
//                        
//                        assert(self.isAsscending())
//                        
//                        continue mainLoop
//                    case .end_b:
//                        // if the intersection point is at the end of the current edge...
//                        
//                        let x = cross.point
//                        
//                        // devide this edge
//                        
//                        self.remove(at: eIndex)
//                        
//                        let thisLt = ShapeEdge(a: thisEdge.a, b: x, count: thisEdge.count)
//                        let thisRt = ShapeEdge(a: x, b: thisEdge.b, count: thisEdge.count)
//                        
//                        _ = self.addAndMerge(thisRt)
//                        eIndex = self.addAndMerge(thisLt)
//                        scanList.removeAllLater(edge: thisLt.edge)
//                        
//                        // new point must be exactly on the same line
//                        let isBend = thisEdge.isNotSameLine(x)
//                        
//                        needToFix = needToFix || isBend
//                        
//                        assert(self.isAsscending())
//                        
//                        continue mainLoop
//                    case .overlay_b:
//                        // split this into 3 segments
//                        
//                        self.remove(at: eIndex)
//                        
//                        let this0 = ShapeEdge(a: thisEdge.a, b: eScan.e0, count: thisEdge.count)
//                        let this1 = ShapeEdge(a: eScan.e0, b: eScan.e1, count: thisEdge.count)
//                        let this2 = ShapeEdge(a: eScan.e1, b: thisEdge.b, count: thisEdge.count)
//                        
//                        _ = self.addAndMerge(this1)
//                        _ = self.addAndMerge(this2)
//                        eIndex = self.addAndMerge(this0)
//                        scanList.removeAllLater(edge: this0.edge)
//                        
//                        // new point must be exactly on the same line
//                        let isBend = thisEdge.isNotSameLine(eScan.e0) || thisEdge.isNotSameLine(eScan.e1)
//                        
//                        needToFix = needToFix || isBend
//                        
//                        assert(self.isAsscending())
//                        
//                        continue mainLoop
//                    case .end_a:
//                        // if the intersection point is at the end of the segment from the scan list...
//                        
//                        let x = cross.point
//
//                        // devide scan segment
//                        
//                        let sIndex = self.findEdgeIndex(eScan)
//                        let scanEdge = self[sIndex]
//                        self.remove(at: sIndex)
//                        
//                        let scanLt = ShapeEdge(a: scanEdge.a, b: x, count: scanEdge.count)
//                        let scanRt = ShapeEdge(a: x, b: scanEdge.b, count: scanEdge.count)
//
//                        _ = self.addAndMerge(scanLt)
//                        _ = self.addAndMerge(scanRt)
//
//                        eIndex = self.findEdgeIndex(thisEdge.edge)
//
//                        // new point must be exactly on the same line
//                        let isBend = scanEdge.isNotSameLine(x)
//                        
//                        needToFix = needToFix || isBend
//                        
//                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt.edge)
//                        
//                        assert(self.isAsscending())
//                        
//                        continue mainLoop
//                    case .overlay_a:
//                        // split scan into 3 segments
//                        
//                        let sIndex = self.findEdgeIndex(eScan)
//                        let scanEdge = self[sIndex]
//                        self.remove(at: sIndex)
//                        
//                        let scan0 = ShapeEdge(a: scanEdge.a, b: thisEdge.a, count: scanEdge.count)
//                        let scan1 = ShapeEdge(a: thisEdge.a, b: thisEdge.b, count: scanEdge.count)
//                        let scan2 = ShapeEdge(a: thisEdge.b, b: scanEdge.b, count: scanEdge.count)
//                        
//                        _ = self.addAndMerge(scan0)
//                        _ = self.addAndMerge(scan1)
//                        _ = self.addAndMerge(scan2)
//
//                        eIndex = self.findEdgeIndex(thisEdge.edge)
//                        
//                        let isBend = scanEdge.isNotSameLine(thisEdge.a) || scanEdge.isNotSameLine(thisEdge.b)
//                        
//                        needToFix = needToFix || isBend
//                        
//                        scanList.replace(oldIndex: scanIndex, newEdge: scan0.edge)
//                        
//                        assert(self.isAsscending())
//                        continue mainLoop
//                    case .penetrate:
//                        // penetrate each other
//                        
//                        let xThis = cross.point
//                        let xScan = cross.second
//                        
//                        let sIndex = self.findEdgeIndex(eScan)
//                        let scanEdge = self[sIndex]
//                        
//                        if eIndex < sIndex {
//                            self.remove(at: sIndex)
//                            self.remove(at: eIndex)
//                        } else {
//                            self.remove(at: eIndex)
//                            self.remove(at: sIndex)
//                        }
//                        
//                        // devide both segments
//                        
//                        let thisLt = ShapeEdge(a: thisEdge.a, b: xThis, count: thisEdge.count)
//                        let thisRt = ShapeEdge(a: xThis, b: thisEdge.b, count: thisEdge.count)
//                        
//                        let scanLt = ShapeEdge(a: scanEdge.a, b: xScan, count: thisEdge.count)
//                        let scanRt = ShapeEdge(a: xScan, b: scanEdge.b, count: thisEdge.count)
//                        
//                        _ = self.addAndMerge(scanLt)
//                        _ = self.addAndMerge(scanRt)
//                        _ = self.addAndMerge(thisLt)
//                        _ = self.addAndMerge(thisRt)
//
//                        // replace current with left part
//                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt.edge)
//                        
//                        if scanLt.isLess(thisLt) {
//                            eIndex = self.findEdgeIndex(scanLt.edge)
//                            scanList.removeAllLater(edge: scanLt.edge)
//                        } else {
//                            eIndex = self.findEdgeIndex(thisLt.edge)
//                            scanList.removeAllLater(edge: thisLt.edge)
//                        }
//
//                        // new point must be exactly on the same line
//                        let isBend = thisEdge.isNotSameLine(xThis) || scanEdge.isNotSameLine(xScan)
//                        
//                        needToFix = needToFix || isBend
//                        
//                        assert(self.isAsscending())
//                        
//                        continue mainLoop
//                    }
//                    
//                } // for scanList
//                
//                // no intersections, add to scan
//                scanList.add(thisEdge.edge)
//                eIndex += 1
//                
//            } // while mainLoop
//            
//            print(ee)
//            ee += 1
//        }
//    }
//   
//}
//
//
//private extension ShapeEdge {
//
//    func cross(_ edge: FixEdge) -> EdgeCross {
//        // y
//
//        let min0: Int64
//        let max0: Int64
//        
//        if a.y > b.y {
//            min0 = a.y
//            max0 = b.y
//        } else {
//            min0 = b.y
//            max0 = a.y
//        }
//
//        let min1: Int64
//        let max1: Int64
//        
//        if edge.e0.y > edge.e1.y {
//            min1 = edge.e1.y
//            max1 = edge.e0.y
//        } else {
//            min1 = edge.e0.y
//            max1 = edge.e1.y
//        }
//
//        let yOverlap = min0 < max1 || max0 > min1
//        
//        if yOverlap {
//            return self.edge.cross(edge)
//        } else {
//            return EdgeCross.notCross
//        }
//    }
//
//    func isNotSameLine(_ point: FixVec) -> Bool {
//        Triangle.isNotLine(p0: a, p1: b, p2: point)
//    }
//}
