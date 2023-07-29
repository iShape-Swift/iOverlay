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
                    case .not_cross, .common_end:
                        break
                    case .pure:
                        isModified = true
                        
                        // If the two segments intersect at a point that isn't an end point of either segment...
                        
                        let x = cross.point
                        
                        let sIndex = self.findEdgeIndex(eScan)
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
                        
                        _ = self.addAndMerge(scanLt)
                        _ = self.addAndMerge(scanRt)
                        _ = self.addAndMerge(thisRt)
                        eIndex = self.addAndMerge(thisLt)

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x) || scanEdge.isNotSameLine(x)
                        
                        isAnyBend = isAnyBend || isBend
                        
                        // replace current with left part
                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                        scanList.removeAllLater(edge: thisLt.edge)
                        
                        assert(self.isAsscending())
                        
                        continue mainLoop
                    case .end_b:
                        isModified = true
                        
                        // if the intersection point is at the end of the current edge...
                        
                        let x = cross.point
                        
                        // devide this edge
                        
                        self.remove(at: eIndex)
                        
                        let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: x, n: thisEdge.n)
                        let thisRt = SelfEdge.safeCreate(a: x, b: thisEdge.b, n: thisEdge.n)
                        
                        _ = self.addAndMerge(thisRt)
                        eIndex = self.addAndMerge(thisLt)

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x)
                        
                        isAnyBend = isAnyBend || isBend

                        scanList.removeAllLater(edge: thisLt.edge)
                        
                        assert(self.isAsscending())
                        
                        continue mainLoop
                    case .end_a:
                        isModified = true
                        
                        // if the intersection point is at the end of the segment from the scan list...
                        
                        let x = cross.point

                        // devide scan segment
                        
                        let sIndex = self.findEdgeIndex(eScan)
                        let scanEdge = self[sIndex]
                        self.remove(at: sIndex)
                        
                        let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: x, n: scanEdge.n)
                        let scanRt = SelfEdge.safeCreate(a: x, b: scanEdge.b, n: scanEdge.n)

                        _ = self.addAndMerge(scanLt)
                        _ = self.addAndMerge(scanRt)

                        eIndex = self.findEdgeIndex(eThis)

                        // new point must be exactly on the same line
                        let isBend = scanEdge.isNotSameLine(x)
                        
                        isAnyBend = isAnyBend || isBend
                        
                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                        
                        assert(self.isAsscending())
                        
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
