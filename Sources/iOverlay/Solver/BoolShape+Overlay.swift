//
//  BoolShape+Overlay.swift
//  
//
//  Created by Nail Sharipov on 29.07.2023.
//

import iFixFloat
import iShape

public extension BoolShape {
    
    mutating func segments(_ clip: inout BoolShape) -> [Segment] {
        guard !self.edges.isEmpty && !clip.edges.isEmpty else { return [] }
        
        self.split(&clip)
        
        let mergeList = self.merge(listA: edges, listB: clip.edges)
        let n = mergeList.count
        var segments = [Segment](repeating: .zero, count: n)
        for i in 0..<n {
            let e = mergeList[i]
            segments[i] = Segment(i: i, a: e.a, b: e.b, fill: 0)
        }
        
        Self.fill(edges: self.edges, segments: &segments, fillTop: .subjectTop, fillBottom: .subjectBottom)
        Self.fill(edges: clip.edges, segments: &segments, fillTop: .clipTop, fillBottom: .clipBottom)
        
        return segments
    }
    
    mutating func overlay(_ clip: inout BoolShape) -> OverlayGraph {
        OverlayGraph(segments: segments(&clip))
    }

    mutating private func split(_ clip: inout BoolShape) {
        guard !clip.edges.isEmpty && !self.edges.isEmpty else {
            return
        }
        
        _ = self.fix()
        _ = clip.fix()

        let selfBnd = FixBnd(minX: self.edges[0].a.x, edges: self.edges)
        let clipBnd = FixBnd(minX: clip.edges[0].a.x, edges: clip.edges)

        var isSubjBend = false
        var isClipBend = false
        
        repeat {

            var scanList = ABScan(edges: clip.edges, bnd: selfBnd)

            var subjIndex = 0
            
        mainLoop:
            while subjIndex < self.edges.count && !scanList.isEmpty {
                
                let thisEdge = self.edges[subjIndex]
                
                guard clipBnd.isCollide(FixBnd(edge: thisEdge)) else {
                    subjIndex += 1
                    continue
                }
                
                let eThis = thisEdge.edge
                
                scanList.startIterate(start: thisEdge.a.bitPack, end: thisEdge.b.bitPack)
                
                var scanRes = scanList.next()
                
                while scanRes.hasNext {
                    
                    let scanEdge = scanRes.edge
                    let eScan = scanEdge.edge
                    let cross = eThis.cross(eScan)
                    
                    switch cross.type {
                    case .not_cross, .common_end:
                        break
                    case .pure:
                        // if the two segments intersect at a point that isn't an end point of either segment...
                        
                        let x = cross.point
                        
                        let clipIndex = clip.edges.findEdgeIndex(eScan)
                        let scanEdge = clip.edges[clipIndex]

                        self.edges.remove(at: subjIndex)
                        clip.edges.remove(at: clipIndex)
                        
                        // devide both segments
                        
                        let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: x, n: thisEdge.n)
                        let thisRt = SelfEdge.safeCreate(a: x, b: thisEdge.b, n: thisEdge.n)
                        
                        let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: x, n: scanEdge.n)
                        let scanRt = SelfEdge.safeCreate(a: x, b: scanEdge.b, n: scanEdge.n)
                        
                        _ = clip.edges.addAndMerge(scanLt)
                        _ = clip.edges.addAndMerge(scanRt)
                        _ = self.edges.addAndMerge(thisRt)
                        subjIndex = self.edges.addAndMerge(thisLt)

                        // new point must be exactly on the same line
                        
                        isSubjBend = isSubjBend || thisEdge.isNotSameLine(x)
                        isClipBend = isClipBend || scanEdge.isNotSameLine(x)
                        
                        scanList.remove(at: scanRes.index)
                        scanList.insert(newEdge: scanLt)
                        scanList.insert(newEdge: scanRt)
                        
                        assert(clip.edges.isAsscending())
                        assert(self.edges.isAsscending())
                        
                        continue mainLoop
                    case .end_b:
                        // if the intersection point is at the end of the current edge...
                        
                        let x = cross.point
                        
                        // devide this edge
                        
                        self.edges.remove(at: subjIndex)
                        
                        let thisLt = SelfEdge.safeCreate(a: thisEdge.a, b: x, n: thisEdge.n)
                        let thisRt = SelfEdge.safeCreate(a: x, b: thisEdge.b, n: thisEdge.n)
                        
                        _ = self.edges.addAndMerge(thisRt)
                        subjIndex = self.edges.addAndMerge(thisLt)

                        // new point must be exactly on the same line
                        isSubjBend = isSubjBend || thisEdge.isNotSameLine(x)
                        
                        assert(self.edges.isAsscending())
                        
                        continue mainLoop
                    case .end_a:
                        // if the intersection point is at the end of the segment from the scan list...
                        
                        let x = cross.point

                        // devide scan segment
                        
                        let clipIndex = clip.edges.findEdgeIndex(eScan)
                        let scanEdge = clip.edges[clipIndex]
                        
                        clip.edges.remove(at: clipIndex)
                        
                        let scanLt = SelfEdge.safeCreate(a: scanEdge.a, b: x, n: scanEdge.n)
                        let scanRt = SelfEdge.safeCreate(a: x, b: scanEdge.b, n: scanEdge.n)

                        _ = clip.edges.addAndMerge(scanLt)
                        _ = clip.edges.addAndMerge(scanRt)

                        isClipBend = isClipBend || scanEdge.isNotSameLine(x)
                        
                        scanList.remove(at: scanRes.index)
                        scanList.insert(newEdge: scanLt)
                        scanList.insert(newEdge: scanRt)
                        
                        assert(clip.edges.isAsscending())
                        
                        continue mainLoop
                    }

                    scanRes = scanList.next()
                }
                
                subjIndex += 1
            }
            
            if isSubjBend {
                isSubjBend = self.fix()
            }
            
            if isClipBend {
                isClipBend = clip.fix()
            }

        } while isSubjBend || isClipBend // root loop
    }

    private func merge(listA: [SelfEdge], listB: [SelfEdge]) -> [SelfEdge] {
        let nA = listA.count
        let nB = listB.count

        var mergeList = [SelfEdge]()
        mergeList.reserveCapacity(nA + nB)
        
        var iA = 0
        var iB = 0

        while iA < nA && iB < nB {
               if listA[iA].isLess(listB[iB]) {
                   mergeList.append(listA[iA])
                   iA += 1
               } else if listA[iA].isEqual(listB[iB]) {
                   mergeList.append(listA[iA])
                   iA += 1
                   iB += 1
               } else {
                   mergeList.append(listB[iB])
                   iB += 1
               }
           }

           while iA < listA.count {
               mergeList.append(listA[iA])
               iA += 1
           }

           while iB < listB.count {
               mergeList.append(listB[iB])
               iB += 1
           }

        return mergeList
    }

}
