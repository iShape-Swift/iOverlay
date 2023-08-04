//
//  SelfEdge+Split.swift
//  
//
//  Created by Nail Sharipov on 20.07.2023.
//

import iFixFloat
import iShape

struct SplitResult {
    let isModified: Bool
    let isGeometryModified: Bool
}

extension Array where Element == SelfEdge {
    
    mutating func split() -> SplitResult {
        var scanList = EdgeScanList()
        
        var isAnyBend = false
        var isGeometryModified = false
        var isModified = false
        
        repeat {
            scanList.clear()
            isAnyBend = false
            
            var eIndex = 0

        mainLoop:
            while eIndex < self.count {
                let thisEdge = self[eIndex]
                
                let scanPos = thisEdge.a.bitPack

                scanList.removeAllEndingBeforePosition(scanPos)
                
                let eThis = thisEdge.edge
                
                // Try to intersect the current segment with all the segments in the scan list.
                for scanIndex in 0..<scanList.edges.count {
                    
                    let eScan = scanList.edges[scanIndex]
                    let cross = eThis.cross(eScan)
                    
                    switch cross.type {
                    case .not_cross:
                        break
                    case .pure:
                        isModified = true
                        
                        // If the two segments intersect at a point that isn't an end point of either segment...
                        
                        let x = cross.point
                        
                        let sIndex = self.aFindEdgeIndex(eScan)
                        let scanEdge = self[sIndex]
                        
                        if eIndex < sIndex {
                            self.remove(at: sIndex)
                            self.remove(at: eIndex)
                        } else {
                            self.remove(at: eIndex)
                            self.remove(at: sIndex)
                        }
                        
                        // devide both segments
                        
                        let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: x, n: thisEdge.n)
                        let thisRt = SelfEdge.safeCreate(a: x, b: thisEdge.b, n: thisEdge.n)
                        
                        let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: x, n: scanEdge.n)
                        let scanRt = SelfEdge.safeCreate(a: x, b: scanEdge.b, n: scanEdge.n)
                        
                        _ = self.aAddAndMerge(scanLt)
                        _ = self.aAddAndMerge(scanRt)
                        _ = self.aAddAndMerge(thisRt)
                        eIndex = self.aAddAndMerge(thisLt)

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x) || scanEdge.isNotSameLine(x)
                        
                        isAnyBend = isAnyBend || isBend
                        
                        // replace current with left part
                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                        scanList.removeAllLater(edge: thisLt.edge)
                        
                        assert(self.isAsscendingA())
                        
                        continue mainLoop
                    case .end_b:
                        isModified = true
                        
                        // if the intersection point is at the end of the current edge...
                        
                        let x = cross.point
                        
                        // devide this edge
                        
                        self.remove(at: eIndex)
                        
                        let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: x, n: thisEdge.n)
                        let thisRt = SelfEdge.safeCreate(a: x, b: thisEdge.b, n: thisEdge.n)
                        
                        _ = self.aAddAndMerge(thisRt)
                        eIndex = self.aAddAndMerge(thisLt)
                        scanList.removeAllLater(edge: thisLt.edge)
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x)
                        
                        isAnyBend = isAnyBend || isBend
                        
                        assert(self.isAsscendingA())
                        
                        continue mainLoop
                    case .overlay_b:
                        isModified = true
                        
                        // split this into 3 segments
                        
                        self.remove(at: eIndex)
                        
                        let this0 = SelfEdge.safeCreate(a: thisEdge.a, b: eScan.e0, n: thisEdge.n)
                        let this1 = SelfEdge.safeCreate(a: eScan.e0, b: eScan.e1, n: thisEdge.n)
                        let this2 = SelfEdge.safeCreate(a: eScan.e1, b: thisEdge.b, n: thisEdge.n)
                        
                        _ = self.aAddAndMerge(this1)
                        _ = self.aAddAndMerge(this2)
                        eIndex = self.aAddAndMerge(this0)
                        scanList.removeAllLater(edge: this0.edge)
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(eScan.e0) || thisEdge.isNotSameLine(eScan.e1)
                        
                        isAnyBend = isAnyBend || isBend
                        
                        assert(self.isAsscendingA())
                        
                        continue mainLoop
                    case .end_a:
                        isModified = true
                        
                        // if the intersection point is at the end of the segment from the scan list...
                        
                        let x = cross.point

                        // devide scan segment
                        
                        let sIndex = self.aFindEdgeIndex(eScan)
                        let scanEdge = self[sIndex]
                        self.remove(at: sIndex)
                        
                        let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: x, n: scanEdge.n)
                        let scanRt = SelfEdge.safeCreate(a: x, b: scanEdge.b, n: scanEdge.n)

                        _ = self.aAddAndMerge(scanLt)
                        _ = self.aAddAndMerge(scanRt)

                        eIndex = self.aFindEdgeIndex(eThis)

                        // new point must be exactly on the same line
                        let isBend = scanEdge.isNotSameLine(x)
                        
                        isAnyBend = isAnyBend || isBend
                        
                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                        
                        assert(self.isAsscendingA())
                        
                        continue mainLoop
                    case .overlay_a:
                        isModified = true
                        
                        // split scan into 3 segments
                        
                        let sIndex = self.aFindEdgeIndex(eScan)
                        let scanEdge = self[sIndex]
                        self.remove(at: sIndex)
                        
                        let scan0 = SelfEdge.safeCreate(a: scanEdge.a, b: thisEdge.a, n: scanEdge.n)
                        let scan1 = SelfEdge.safeCreate(a: thisEdge.a, b: thisEdge.b, n: scanEdge.n)
                        let scan2 = SelfEdge.safeCreate(a: thisEdge.b, b: scanEdge.b, n: scanEdge.n)
                        
                        _ = self.aAddAndMerge(scan0)
                        _ = self.aAddAndMerge(scan1)
                        _ = self.aAddAndMerge(scan2)

                        eIndex = self.aFindEdgeIndex(eThis)
                        
                        let isBend = scanEdge.isNotSameLine(thisEdge.a) || scanEdge.isNotSameLine(thisEdge.b)
                        
                        isAnyBend = isAnyBend || isBend
                        
                        scanList.replace(oldIndex: scanIndex, newEdge: scan0)
                        
                        assert(self.isAsscendingA())
                        continue mainLoop
                    case .penetrate:
                        isModified = true
                        
                        // penetrate each other
                        
                        let xThis = cross.point
                        let xScan = cross.second
                        
                        let sIndex = self.aFindEdgeIndex(eScan)
                        let scanEdge = self[sIndex]
                        
                        if eIndex < sIndex {
                            self.remove(at: sIndex)
                            self.remove(at: eIndex)
                        } else {
                            self.remove(at: eIndex)
                            self.remove(at: sIndex)
                        }
                        
                        // devide both segments
                        
                        let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: xThis, n: thisEdge.n)
                        let thisRt = SelfEdge.safeCreate(a: xThis, b: thisEdge.b, n: thisEdge.n)
                        
                        let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: xScan, n: scanEdge.n)
                        let scanRt = SelfEdge.safeCreate(a: xScan, b: scanEdge.b, n: scanEdge.n)
                        
                        _ = self.aAddAndMerge(scanLt)
                        _ = self.aAddAndMerge(scanRt)
                        _ = self.aAddAndMerge(thisLt)
                        _ = self.aAddAndMerge(thisRt)

                        // replace current with left part
                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                        
                        if scanLt.isLessA(thisLt) {
                            eIndex = self.aFindEdgeIndex(scanLt.edge)
                            scanList.removeAllLater(edge: scanLt.edge)
                        } else {
                            eIndex = self.aFindEdgeIndex(thisLt.edge)
                            scanList.removeAllLater(edge: thisLt.edge)
                        }

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(xThis) || scanEdge.isNotSameLine(xScan)
                        
                        isAnyBend = isAnyBend || isBend
                        
                        assert(self.isAsscendingA())
                        
                        continue mainLoop
                    }
                    
                } // for scanList
                
                // no intersections, add to scan
                scanList.add(thisEdge.edge)
                eIndex += 1
                
            } // while mainLoop

            isGeometryModified = isGeometryModified || isAnyBend
            
        } while isAnyBend

#if DEBUG
        assert(Set(self).count == count)
#endif
        
        return SplitResult(isModified: isModified, isGeometryModified: isGeometryModified)
    }
   
}
