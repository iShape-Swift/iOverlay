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
        
        _ = self.fix(force: false)
        _ = clip.fix(force: false)

        let clipBnd = FixBnd(edges: clip.edges)

        clip.sortDescending()
        
        var isSubjBend = false
        var isClipBend = false
        var isAnypBend = false
        
        repeat {

            var subjIndex = 0
            
        mainLoop:
            while subjIndex < self.edges.count {
                
                let subjEdge = self.edges[subjIndex]

                guard clipBnd.isCollide(FixBnd(edge: subjEdge)) else {
                    subjIndex += 1
                    continue
                }

                var clipIndex = clip.edges.bFindMore(subjEdge.a)
                let clipEnd = subjEdge.b.bitPack
                
                while clipIndex <= clip.edges.count {

                    let clipEdge = clip.edges[clipIndex]
                    
                    guard clipEdge.b.bitPack < clipEnd else {
                        subjIndex += 1
                        break
                    }

                    let cross = subjEdge.edge.cross(clipEdge.edge)
                    
                    switch cross.type {
                    case .not_cross:
                        break
                    case .pure:
                        // common intersections
                        
                        let x = cross.point

                        self.edges.remove(at: subjIndex)
                        clip.edges.remove(at: clipIndex)
                        
                        // devide both segments
                        
                        let subjLt = SelfEdge.safeCreate(a: subjEdge.a, b: x, n: subjEdge.n)
                        let subjRt = SelfEdge.safeCreate(a: x, b: subjEdge.b, n: subjEdge.n)
                        
                        let clipLt = SelfEdge.safeCreate(a: clipEdge.a, b: x, n: clipEdge.n)
                        let clipRt = SelfEdge.safeCreate(a: x, b: clipEdge.b, n: clipEdge.n)
                        
                        _ = clip.edges.bAddAndMerge(clipLt)
                        _ = clip.edges.bAddAndMerge(clipRt)
                        
                        _ = self.edges.aAddAndMerge(subjRt)
                        subjIndex = self.edges.aAddAndMerge(subjLt)

                        // new point must be exactly on the same line
                        
                        isSubjBend = isSubjBend || subjEdge.isNotSameLine(x)
                        isClipBend = isClipBend || clipEdge.isNotSameLine(x)

                        assert(clip.edges.isAsscendingB())
                        assert(self.edges.isAsscendingA())
                        
                        continue mainLoop
                    case .end_b:
                        // clip edge end split subj edge
                        
                        let x = cross.point
                        
                        // devide subj edge
                        
                        self.edges.remove(at: subjIndex)
                        
                        let subjLt = SelfEdge.safeCreate(a: subjEdge.a, b: x, n: subjEdge.n)
                        let subjRt = SelfEdge.safeCreate(a: x, b: subjEdge.b, n: subjEdge.n)
                        
                        _ = self.edges.aAddAndMerge(subjRt)
                        subjIndex = self.edges.aAddAndMerge(subjLt)

                        // new point must be exactly on the same line
                        isSubjBend = isSubjBend || subjEdge.isNotSameLine(x)
                        
                        assert(self.edges.isAsscendingA())
                        
                        continue mainLoop
                    case .overlay_b:
                        // subj edge is overlayed by clip edge

                        // split subj into 3 segments
                        
                        self.edges.remove(at: subjIndex)
                        
                        let subj0 = SelfEdge.safeCreate(a: subjEdge.a, b: clipEdge.a, n: subjEdge.n)
                        let subj1 = SelfEdge.safeCreate(a: clipEdge.a, b: clipEdge.b, n: subjEdge.n)
                        let subj2 = SelfEdge.safeCreate(a: clipEdge.b, b: subjEdge.b, n: subjEdge.n)
                        
                        _ = self.edges.aAddAndMerge(subj1)
                        _ = self.edges.aAddAndMerge(subj2)
                        subjIndex = self.edges.aAddAndMerge(subj0)

                        // new points must be exactly on the same line
                        isSubjBend = isSubjBend || subjEdge.isNotSameLine(clipEdge.a) || subjEdge.isNotSameLine(clipEdge.b)
                        
                        assert(self.edges.isAsscendingA())
                        
                        continue mainLoop
                    case .end_a:
                        // subj edge end split clip edge
                        
                        let x = cross.point

                        // devide clip edge
                        
                        clip.edges.remove(at: clipIndex)
                        
                        let clipLt = SelfEdge.safeCreate(a: clipEdge.a, b: x, n: clipEdge.n)
                        let clipRt = SelfEdge.safeCreate(a: x, b: clipEdge.b, n: clipEdge.n)

                        _ = clip.edges.bAddAndMerge(clipLt)
                        _ = clip.edges.bAddAndMerge(clipRt)

                        // new point must be exactly on the same line
                        isClipBend = isClipBend || clipEdge.isNotSameLine(x)
                        
                        assert(clip.edges.isAsscendingB())
                        
                        continue mainLoop
                    case .overlay_a:
                        // clip edge is overlayed by subj edge
                        
                        // split clip into 3 segments
                        
                        clip.edges.remove(at: clipIndex)
                        
                        let clip0 = SelfEdge.safeCreate(a: clipEdge.a, b: subjEdge.a, n: clipEdge.n)
                        let clip1 = SelfEdge.safeCreate(a: subjEdge.a, b: subjEdge.b, n: clipEdge.n)
                        let clip2 = SelfEdge.safeCreate(a: subjEdge.b, b: clipEdge.b, n: clipEdge.n)

                        _ = clip.edges.bAddAndMerge(clip0)
                        _ = clip.edges.bAddAndMerge(clip1)
                        _ = clip.edges.bAddAndMerge(clip2)

                        // new points must be exactly on the same line
                        isClipBend = isClipBend || clipEdge.isNotSameLine(subjEdge.a) || clipEdge.isNotSameLine(subjEdge.b)
                        
                        assert(clip.edges.isAsscendingB())
                        
                        continue mainLoop
                    case .penetrate:
                        // penetrate each other
                        
                        let xSubj = cross.point
                        let xClip = cross.second

                        self.edges.remove(at: subjIndex)
                        clip.edges.remove(at: clipIndex)
                        
                        // devide both segments
                        
                        let subjLt = SelfEdge.safeCreate(a: subjEdge.a, b: xSubj, n: subjEdge.n)
                        let subjRt = SelfEdge.safeCreate(a: xSubj, b: subjEdge.b, n: subjEdge.n)
                        
                        let clipLt = SelfEdge.safeCreate(a: clipEdge.a, b: xClip, n: clipEdge.n)
                        let clipRt = SelfEdge.safeCreate(a: xClip, b: clipEdge.b, n: clipEdge.n)
                        
                        _ = clip.edges.bAddAndMerge(clipLt)
                        _ = clip.edges.bAddAndMerge(clipRt)
                        
                        _ = self.edges.aAddAndMerge(subjRt)
                        subjIndex = self.edges.aAddAndMerge(subjLt)

                        // new point must be exactly on the same line
                        
                        isSubjBend = isSubjBend || subjEdge.isNotSameLine(xSubj)
                        isClipBend = isClipBend || clipEdge.isNotSameLine(xClip)
                        
                        assert(clip.edges.isAsscendingB())
                        assert(self.edges.isAsscendingA())
                        
                        continue mainLoop
                    }
                    
                    clipIndex += 1
                }
            } // main loop
            
            isAnypBend = isSubjBend || isClipBend
            
            if isSubjBend {
                isSubjBend = self.fix(force: true)
            }
            
            if isClipBend {
                isClipBend = clip.fix(force: true)
                clip.sortDescending()
            }

        } while isAnypBend // root loop
    }

    private func merge(listA: [SelfEdge], listB: [SelfEdge]) -> [SelfEdge] {
        let nA = listA.count
        let nB = listB.count

        var mergeList = [SelfEdge]()
        mergeList.reserveCapacity(nA + nB)
        
        var iA = 0
        var iB = 0

        while iA < nA && iB < nB {
               if listA[iA].isLessA(listB[iB]) {
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
