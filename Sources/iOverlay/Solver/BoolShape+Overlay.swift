//
//  BoolShape+Overlay.swift
//  
//
//  Created by Nail Sharipov on 29.07.2023.
//

import iFixFloat

public extension BoolShape {
    
    mutating func overlay(_ clip: inout BoolShape) {
        self.split(&clip)
        
        
        
        
    }

    mutating private func split(_ clip: inout BoolShape) {

        _ = self.fix()
        _ = clip.fix()

        var clipScanList = EdgeScanList()
        var subjScanList = EdgeScanList()
        
        var isSubjBend = false
        var isClipBend = false
        
        repeat {
            subjScanList.clear()
            clipScanList.clear()
            
            var subjIndex = 0
            var clipIndex = 0

            var isSubjOver = false
            var isClipOver = false
            
            while !isSubjOver || !isClipOver {
                
                let fixedSubjIndex = isSubjOver ? self.edges.count - 1 : subjIndex
                let fixedClipIndex = isClipOver ? clip.edges.count - 1 : clipIndex
                
                let subjEdge = self.edges[fixedSubjIndex]
                let clipEdge = clip.edges[fixedClipIndex]
                
                let iterateSubj = subjEdge.a.bitPack < clipEdge.a.bitPack && !isSubjOver || isClipOver
                
                if iterateSubj {
                    let result = BoolShape.intersectEdge(
                        mainIndex: subjIndex,
                        otherIndex: fixedClipIndex,
                        scanList: &clipScanList,
                        mainEdges: &self.edges,
                        otherEdges: &clip.edges
                    )
                    
                    if result.isIntersect {
                        subjIndex = result.mainIndex
                        clipIndex = result.otherIndex
                        isSubjBend = isSubjBend || result.isMainBend
                        isClipBend = isClipBend || result.isOtherBend
                    } else {
                        subjScanList.add(subjEdge.edge)
                        subjIndex += 1
                    }
                } else {
                    let result = BoolShape.intersectEdge(
                        mainIndex: clipIndex,
                        otherIndex: fixedSubjIndex,
                        scanList: &subjScanList,
                        mainEdges: &clip.edges,
                        otherEdges: &self.edges
                    )
                    
                    if result.isIntersect {
                        subjIndex = result.otherIndex
                        clipIndex = result.mainIndex
                        isSubjBend = isSubjBend || result.isOtherBend
                        isClipBend = isClipBend || result.isMainBend
                    } else {
                        clipScanList.add(clipEdge.edge)
                        clipIndex += 1
                    }
                }
                
                isSubjOver = subjIndex >= self.edges.count
                isClipOver = clipIndex >= clip.edges.count
            }
            
            if isSubjBend {
                isSubjBend = self.fix()
            }
            
            if isClipBend {
                isClipBend = clip.fix()
            }

        } while isSubjBend || isClipBend // root loop
    }
    
    private struct IntersectEdgeResult {
        let mainIndex: Int
        let otherIndex: Int
        let isMainBend: Bool
        let isOtherBend: Bool
        let isIntersect: Bool
    }
    
    private static func intersectEdge(
        mainIndex: Int,
        otherIndex: Int,
        scanList: inout EdgeScanList,
        mainEdges: inout [SelfEdge],
        otherEdges: inout [SelfEdge]
    ) -> IntersectEdgeResult {

        let thisEdge = mainEdges[mainIndex]
        
        scanList.removeAllEndingBeforePosition(thisEdge.a.bitPack)
        
        let eThis = thisEdge.edge
        
        // Try to intersect the current edge with all the edges in the scan list.
        for scanIndex in 0..<scanList.edges.count {

            let eScan = scanList.edges[scanIndex]
            let cross = eThis.cross(eScan)

            switch cross.type {
            case .not_cross, .common_end:
                break
            case .pure:
                // If the two edges intersect at a point that isn't an end point of either edge...

                let x = cross.point

                let sIndex = otherEdges.findEdgeIndex(eScan)
                let scanEdge = otherEdges[sIndex]
                let otherEdge = otherEdges[otherIndex]

                mainEdges.remove(at: mainIndex)
                otherEdges.remove(at: sIndex)

                // devide both edges

                let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: x, n: thisEdge.n)
                let thisRt = SelfEdge.safeCreate(a: x, b: thisEdge.b, n: thisEdge.n)

                let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: x, n: scanEdge.n)
                let scanRt = SelfEdge.safeCreate(a: x, b: scanEdge.b, n: scanEdge.n)

                let scanLtIndex = otherEdges.addAndMerge(scanLt)
                let scanRtIndex = otherEdges.addAndMerge(scanRt)
                _ = mainEdges.addAndMerge(thisRt)

                let newMainIndex = mainEdges.addAndMerge(thisLt)
                
                let newOtherIndex: Int
                if sIndex == otherIndex {
                    newOtherIndex = scanLtIndex
                } else if otherEdge.a.bitPack < scanRt.a.bitPack {
                    newOtherIndex = otherEdges.findEdgeIndex(otherEdge.edge)
                } else {
                    newOtherIndex = scanRtIndex
                }

                // new point must be exactly on the same line
                let isMainBend = thisEdge.isNotSameLine(x)
                let isOtherBend = scanEdge.isNotSameLine(x)

                // replace current with left part
                scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                scanList.removeAllAfter(edge: otherEdges[newOtherIndex].edge)

                assert(mainEdges.isAsscending())
                assert(otherEdges.isAsscending())

                return IntersectEdgeResult(
                    mainIndex: newMainIndex,
                    otherIndex: newOtherIndex,
                    isMainBend: isMainBend,
                    isOtherBend: isOtherBend,
                    isIntersect: true
                )
            case .end_b:
                // If the intersection point is at the end of the current edge...

                let x = cross.point
                
                // devide this edge

                mainEdges.remove(at: mainIndex)

                let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: x, n: thisEdge.n)
                let thisRt = SelfEdge.safeCreate(a: x, b: thisEdge.b, n: thisEdge.n)

                _ = mainEdges.addAndMerge(thisRt)
                let newMainIndex = mainEdges.addAndMerge(thisLt)

                // new point must be exactly on the same line
                let isMainBend = thisEdge.isNotSameLine(x)

                assert(mainEdges.isAsscending())

                return IntersectEdgeResult(
                    mainIndex: newMainIndex,
                    otherIndex: otherIndex, // we are not modify otherEdges
                    isMainBend: isMainBend,
                    isOtherBend: false,
                    isIntersect: true
                )
            case .end_a:
                // if the intersection point is at the end of the edge from the scan list...

                let x = cross.point

                let otherEdge = otherEdges[otherIndex]
                
                // devide scan edge

                let sIndex = otherEdges.findEdgeIndex(eScan)
                let scanEdge = otherEdges[sIndex]

                otherEdges.remove(at: sIndex)

                let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: x, n: scanEdge.n)
                let scanRt = SelfEdge.safeCreate(a: x, b: scanEdge.b, n: scanEdge.n)

                let scanLtIndex = otherEdges.addAndMerge(scanLt)
                let scanRtIndex = otherEdges.addAndMerge(scanRt)

                let newOtherIndex: Int
                if otherEdge.a.bitPack < scanRt.a.bitPack {
                    if sIndex == otherIndex {
                        newOtherIndex = scanLtIndex
                    } else {
                        newOtherIndex = otherEdges.findEdgeIndex(otherEdge.edge)
                    }
                } else {
                    newOtherIndex = scanRtIndex
                }

                // new point must be exactly on the same line
                let isOtherBend = scanEdge.isNotSameLine(x)

                scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                scanList.removeAllAfter(edge: otherEdges[newOtherIndex].edge)
                
                assert(otherEdges.isAsscending())

                return IntersectEdgeResult(
                    mainIndex: mainIndex,
                    otherIndex: newOtherIndex,
                    isMainBend: false,
                    isOtherBend: isOtherBend,
                    isIntersect: true
                )
            }

        } // for scanList
        
        return IntersectEdgeResult(
            mainIndex: mainIndex,
            otherIndex: otherIndex,
            isMainBend: false,
            isOtherBend: false,
            isIntersect: false
        )
    }

}
