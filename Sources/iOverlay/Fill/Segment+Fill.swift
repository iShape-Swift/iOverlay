//
//  Segment+Fill.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape

private struct Handler {
    let i: Int
    let y: Int32
}

private struct SegEnd {
    let i: Int
    let p: Point
}

extension Array where Element == Segment {
    
    mutating func fill(fillRule: FillRule, range: LineRange) {
        var scanList = XScanList(range: range, count: self.count)
        
        var counts = [ShapeCount](repeating: ShapeCount(subj: 0, clip: 0), count: self.count)
        var xBuf = [Handler]()
        var eBuf = [SegEnd]()
        var candidates = [Int]()
       
        let n = self.count
        var i = 0

        while i < n {
            let x = self[i].seg.a.x
            xBuf.removeAll(keepingCapacity: true)
            
            // find all new segments with same a.x
            
            while i < n && self[i].seg.a.x == x {
                xBuf.append(Handler(i: i, y: self[i].seg.a.y))
                i += 1
            }
            
            if xBuf.count > 1 {
                // sort all by a.y
                xBuf.sort(by: { $0.y < $1.y })
            }
            
            // find nearest segment from scan list for all new segments
            
            var j = 0
            while j < xBuf.count {
                
                let y = xBuf[j].y

                eBuf.removeAll(keepingCapacity: true)
                
                // group new segments by same y (all segments in eBuf must have same a)
                while j < xBuf.count && xBuf[j].y == y {
                    let handler = xBuf[j]
                    eBuf.append(SegEnd(i: handler.i, p: self[handler.i].seg.b))
                    j += 1
                }
                
                let p = Point(x, y)
                
                if eBuf.count > 1 {
                    eBuf.sortByAngle(center: p)
                }

                // find nearest scan segment for y
                var iterator = scanList.iteratorToBottom(start: y)
                var bestSegment: XSegment?
                var bestIndex: Int = .max
                
                while iterator.min != .min {
                    scanList.space.idsInRange(range: iterator, stop: x, ids: &candidates)
                    if !candidates.isEmpty {
                        
                        for segIndex in candidates {
                            let segment = self[segIndex].seg
                            if segment.isUnder(point: p) {
                                if let bestSeg = bestSegment {
                                    if bestSeg.isUnder(segment: segment) {
                                        bestSegment = segment
                                        bestIndex = segIndex
                                    }
                                } else {
                                    bestSegment = segment
                                    bestIndex = segIndex
                                }
                            }
                        }
                        candidates.removeAll(keepingCapacity: true)
                    }
                    
                    if let bestSeg = bestSegment, bestSeg.isAbove(point: Point(x: x, y: iterator.min)) {
                        break
                    }

                    iterator = scanList.next(range: iterator)
                }

                var sumCount: ShapeCount
                if bestIndex != .max {
                    sumCount = counts[bestIndex]
                } else {
                    // this is the most bottom segment group
                    sumCount = ShapeCount(subj: 0, clip: 0)
                }

                for se in eBuf {
                    if self[se.i].seg.isVertical {
                        _ = self[se.i].addAndFill(sumCount: sumCount, fillRule: fillRule)
                    } else {
                        sumCount = self[se.i].addAndFill(sumCount: sumCount, fillRule: fillRule)
                        counts[se.i] = sumCount
                        let seg = self[se.i].seg
                        scanList.space.insert(segment: ScanSegment(
                            id: se.i,
                            range: seg.yRange,
                            stop: seg.b.x
                        ))
                    }
                }
            }
        }
    }
}

private extension Segment {

    mutating func addAndFill(sumCount: ShapeCount, fillRule: FillRule) -> ShapeCount {
        let newCount = sumCount.add(count)
        self.fill(sumCount: sumCount, newCount: newCount, fillRule: fillRule)
        return newCount
    }
    
    private mutating func fill(sumCount: ShapeCount, newCount: ShapeCount, fillRule: FillRule) {
        let isSubjTop: Bool
        let isSubjBottom: Bool
        let isClipTop: Bool
        let isClipBottom: Bool
        
        switch fillRule {
        case .evenOdd:
            isSubjTop = 1 & newCount.subj == 1
            isSubjBottom = 1 & sumCount.subj == 1

            isClipTop = 1 & newCount.clip == 1
            isClipBottom = 1 & sumCount.clip == 1
        case .nonZero:
            isSubjTop = newCount.subj != 0
            isSubjBottom = sumCount.subj != 0
            
            isClipTop = newCount.clip != 0
            isClipBottom = sumCount.clip != 0
        }
        
        let subjTop = isSubjTop ? SegmentFill.subjectTop : 0
        let subjBottom = isSubjBottom ? SegmentFill.subjectBottom : 0
        let clipTop = isClipTop ? SegmentFill.clipTop : 0
        let clipBottom = isClipBottom ? SegmentFill.clipBottom : 0
        
        fill = subjTop | subjBottom | clipTop | clipBottom
    }
    
}

private extension Array where Element == SegEnd {
    
    mutating func sortByAngle(center: Point) {
        let c = FixVec(center)
        self.sort(by: {
            Triangle.isClockwise(p0: c, p1: FixVec($1.p), p2: FixVec($0.p))
        })
    }
    
}
