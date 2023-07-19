//
//  Array+Split.swift
//  
//
//  Created by Nail Sharipov on 13.07.2023.
//

import iFixFloat
import iShape

extension Array where Element == Segment {
    
    mutating func split(vStore: inout VStore) {
        var scanList = ScanList()
        
        var segIndex = 0
        
        // Begin processing all the segments in the array.
    mainLoop:
        while segIndex < self.count {
            let thisSeg = self[segIndex]
            
            let scanPos = thisSeg.a.point.bitPack

            scanList.removeSegmentsEndingBeforePosition(scanPos)
            
            // Try to intersect the current segment with all the segments in the scan list.
            for scanIndex in 0..<scanList.segments.count {
                
                let scanSeg = scanList.segments[scanIndex]
                
                let cross = thisSeg.cross(scanSeg)
                
                switch cross.type {
                case .not_cross, .common_end:
                    break
                case .pure:
                    // If the two segments intersect at a point that isn't an end point of either segment...
                    
                    let x = vStore.indexPoint(s0: thisSeg, s1: scanSeg, point: cross.point)
                    
                    // devide both segments
                    
                    let thisLt = Segment(a: thisSeg.a, b: x)
                    let thisRt = Segment(a: x, b: thisSeg.b)
                    
                    let scanLt = Segment(a: scanSeg.a, b: x)
                    let scanRt = Segment(a: x, b: scanSeg.b)
                    
                    _ = self.replace(oldSegment: scanSeg, newSegment: scanLt)
                    self.insertIfNotExist(scanRt)

                    // order could be modified so we will continue with thisLt index
                    segIndex = self.replace(oldSegment: thisSeg, newSegment: thisLt)
                    
                    // thisRt do not make impact to segIndex cause thisLt.a < thisRt.a
                    self.insertIfNotExist(thisRt)

                    // new point must be exactly on the same line
                    let isBend = thisSeg.isNotSameLine(x.point) || scanSeg.isNotSameLine(x.point)
                    
                    // if the new intersection point causes the segments to be non-collinear...
                    if isBend {
                        
                        assert(scanLt.a.point.bitPack < thisLt.a.point.bitPack)
                        
                        // roll back before scanLt.a
                        let newScanPos = scanLt.a.point.bitPack - 1
                        segIndex = self.findIndexByA(newScanPos)

                        // add all segments which can overlap newScanPos
                        scanList.fill(self, withFirst: segIndex, overlay: newScanPos)
                        
                        debugPrint("roolback to index: \(segIndex)")
                    } else {
                        // replace current with left part
                        scanList.replace(oldIndex: scanIndex, newSegment: scanLt)
                    }
                    
                    continue mainLoop
                case .end_b:
                    // if the intersection point is at the end of the current segment...
                    
                    let x = vStore.indexPoint(s0: thisSeg, s1: scanSeg, point: cross.point)
                    
                    // devide this segment
                    
                    let thisLt = Segment(a: thisSeg.a, b: x)
                    let thisRt = Segment(a: x, b: thisSeg.b)

                    // order could be modified so we will continue with thisLt index
                    segIndex = self.replace(oldIndex: segIndex, newSegment: thisLt)
                    
                    // thisRt do not make impact to segIndex cause thisLt.a < thisRt.a
                    self.insertIfNotExist(thisRt)

                    // new point must be exactly on the same line
                    let isBend = thisSeg.isNotSameLine(x.point)
                    
                    // if the new intersection point causes the segments to be non-collinear...
                    if isBend {

                        // roll back before thisLt.a
                        let newScanPos = thisLt.a.point.bitPack - 1
                        segIndex = self.findIndexByA(newScanPos)

                        // add all segments which can overlap newScanPos
                        scanList.fill(self, withFirst: segIndex, overlay: newScanPos)
                        
                        debugPrint("roolback to index: \(segIndex)")
                    }

                    continue mainLoop
                case .end_a:
                    // if the intersection point is at the end of the segment from the scan list...
                    
                    let x = vStore.indexPoint(s0: thisSeg, s1: scanSeg, point: cross.point)

                    // devide scan segment
                    
                    let scanLt = Segment(a: scanSeg.a, b: x)
                    let scanRt = Segment(a: x, b: scanSeg.b)
                    
                    _ = self.replace(oldSegment: scanSeg, newSegment: scanLt)
                    self.insertIfNotExist(scanRt)

                    // order could be modified so we must revalidate index
                    segIndex = self.segmentIndex(thisSeg)

                    // new point must be exactly on the same line
                    let isBend = scanSeg.isNotSameLine(x.point)
                    
                    // if the new intersection point causes the segments to be non-collinear...
                    if isBend {
                        
                        // roll back before scanLt.a
                        let newScanPos = scanLt.a.point.bitPack - 1
                        segIndex = self.findIndexByA(newScanPos)

                        // add all segments which can overlap newScanPos
                        scanList.fill(self, withFirst: segIndex, overlay: newScanPos)
                        
                        debugPrint("roolback to index: \(segIndex)")
                    } else {
                        // replace current with left part
                        scanList.replace(oldIndex: scanIndex, newSegment: scanLt)
                    }
                    
                    continue mainLoop
                }
                
            } // for scanList
            
            // no intersections, add to scan
            scanList.add(thisSeg)
            segIndex += 1
            
        } // while queue
        
        
#if DEBUG
        assert(Set(self).count == count)
#endif
    }
    
}

private struct ScanList {
    
    var segments: [Segment]
    private var minEnd: Int64
    
    init() {
        self.segments = [Segment]()
        self.segments.reserveCapacity(8)
        self.minEnd = .max
    }
    
    mutating func add(_ segment: Segment) {
        segments.append(segment)
        minEnd = min(minEnd, segment.b.point.bitPack)
    }
    
    mutating func removeSegmentsEndingBeforePosition(_ pos: Int64) {
        guard minEnd <= pos else { return } // if segments is empty then minEnd === .max
        var minPos = Int64.max
        var i = 0
        var j = segments.count - 1
        var n = 0
        while i <= j {
            let seg = segments[i]
            let bPos = seg.b.point.bitPack
            if bPos <= pos {
                segments[i] = segments[j]
                j -= 1
                n += 1
            } else {
                i += 1
                minPos = min(minPos, bPos)
            }
        }
        minEnd = minPos
        segments.removeLast(n)
    }

    mutating func fill(_ list: [Segment], withFirst count: Int, overlay pos: Int64) {
        segments.removeAll(keepingCapacity: true)
        self.minEnd = .max
        for i in 0..<count {
            let seg = list[i]
            let bPos = seg.b.point.bitPack
            if bPos > pos {
                segments.append(seg)
                minEnd = min(minEnd, bPos)
            }
        }
    }
    
    mutating func replace(oldIndex: Int, newSegment: Segment) {
        if self.isContain(newSegment) {
            // newSegment is exist, but we still must remove oldSegment
            segments.remove(at: oldIndex)
        } else {
            // newSegment is not exist, so we only update old segment
            segments[oldIndex] = newSegment
        }
    }
    
    private func isContain(_ seg: Segment) -> Bool {
        for segment in segments where segment == seg {
            return true
        }
        return false
    }
    
}

private extension VStore {
    
    private func mask(segment: Segment) -> ShapeMask {
        let am = self.point(index: segment.a.index).mask
        let bm = self.point(index: segment.b.index).mask
        
        return am & bm
    }
    
    mutating func indexPoint(s0: Segment, s1: Segment, point: FixVec) -> IndexPoint {
        let m0 = self.mask(segment: s0)
        let m1 = self.mask(segment: s1)

        let index = self.put(point: point, mask: m0 | m1)
        
        return IndexPoint(index: index, point: point)
    }
    
}

private extension Segment {
    
    func isNotSameLine(_ point: FixVec) -> Bool {
        Triangle.isNotLine(p0: a.point, p1: b.point, p2: point)
    }
    
}
