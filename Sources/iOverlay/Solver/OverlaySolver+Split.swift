//
//  OverlaySolver+Split.swift
//  
//
//  Created by Nail Sharipov on 28.07.2023.
//

extension OverlaySolver {

    static func split(subject: inout BoolShape, clip: inout BoolShape) {
        
        _ = subject.fix()
        _ = clip.fix()

        var scanList = EdgeScanList()
        
        var isSubBend = false
        var isClipBend = false
        
        while isSubBend || isClipBend {
            
            var clipIndex = 0
            var eIndex = 0
            scanList.clear()
            
        mainLoop:
            while eIndex < subject.edges.count {
                let thisEdge = subject.edges[eIndex]
                
                let scanPos = thisEdge.a.bitPack

                scanList.removeAllEndingBeforePosition(scanPos)
                clipIndex = scanList.addAllOverlapingPosition(scanPos, start: clipIndex, list: clip.edges)
                
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
                        
                        let sIndex = clip.edges.findEdgeIndex(eScan)
                        let scanEdge = clip.edges[sIndex]
                        
                        subject.edges.remove(at: eIndex)
                        clip.edges.remove(at: sIndex)
                        
                        // devide both edges
                        
                        let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: x, n: thisEdge.n)
                        let thisRt = SelfEdge.safeCreate(a: x, b: thisEdge.b, n: thisEdge.n)
                        
                        let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: x, n: scanEdge.n)
                        let scanRt = SelfEdge.safeCreate(a: x, b: scanEdge.b, n: scanEdge.n)
                        
                        _ = clip.edges.addAndMerge(scanLt)
                        _ = clip.edges.addAndMerge(scanRt)
                        _ = subject.edges.addAndMerge(thisRt)
                        eIndex = subject.edges.addAndMerge(thisLt)

                        // new point must be exactly on the same line
                        isSubBend = isSubBend || thisEdge.isNotSameLine(x)
                        isClipBend = isClipBend || scanEdge.isNotSameLine(x)
                        
                        // replace current with left part
                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                        scanList.removeAllLater(edge: thisLt.edge)
                        
                        assert(subject.edges.isAsscending())
                        assert(clip.edges.isAsscending())
                        
                        continue mainLoop
                    case .end_b:
                        // If the intersection point is at the end of the current edge...
                        
                        let x = cross.point
                        
                        // devide this edge
                        
                        subject.edges.remove(at: eIndex)
                        
                        let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: x, n: thisEdge.n)
                        let thisRt = SelfEdge.safeCreate(a: x, b: thisEdge.b, n: thisEdge.n)
                        
                        _ = subject.edges.addAndMerge(thisRt)
                        eIndex = subject.edges.addAndMerge(thisLt)

                        // new point must be exactly on the same line
                        isSubBend = isSubBend || thisEdge.isNotSameLine(x)

                        scanList.removeAllLater(edge: thisLt.edge)
                        
                        assert(subject.edges.isAsscending())
                        
                        continue mainLoop
                    case .end_a:
                        // if the intersection point is at the end of the edge from the scan list...
                        
                        let x = cross.point

                        // devide scan edge
                        
                        let sIndex = clip.edges.findEdgeIndex(eScan)
                        let scanEdge = clip.edges[sIndex]
                        
                        clip.edges.remove(at: sIndex)
                        
                        let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: x, n: scanEdge.n)
                        let scanRt = SelfEdge.safeCreate(a: x, b: scanEdge.b, n: scanEdge.n)

                        _ = clip.edges.addAndMerge(scanLt)
                        _ = clip.edges.addAndMerge(scanRt)

                        eIndex = clip.edges.findEdgeIndex(eThis)

                        // new point must be exactly on the same line
                        isClipBend = isClipBend || scanEdge.isNotSameLine(x)
                        
                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                        
                        assert(clip.edges.isAsscending())
                        
                        continue mainLoop
                    }
                    
                } // for scanList

                eIndex += 1
            } // while mainLoop
            
            if isSubBend {
                isSubBend = subject.fix()
            }
            
            if isClipBend {
                isClipBend = clip.fix()
            }

        } // root loop
    }
    
}
