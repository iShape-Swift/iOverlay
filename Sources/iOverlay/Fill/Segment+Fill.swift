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
    let p: FixVec
}

extension Array where Element == Segment {
    
    mutating func fill(fillRule: FillRule, range: LineRange) {
        var scanList = FillScanList(range: range, count: self.count)
        
        var counts = [ShapeCount](repeating: ShapeCount(subj: 0, clip: 0), count: self.count)
        var xBuf = [Handler]()
        var eBuf = [SegEnd]()
        var candidates = [Int]()
       
        let n = self.count
        var i = 0

        while i < n {
            let x = self[i].a.x
            xBuf.removeAll(keepingCapacity: true)
            
            // find all new segments with same a.x
            
            while i < n && self[i].a.x == x {
                xBuf.append(Handler(i: i, y: Int32(self[i].a.y)))
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
                    eBuf.append(SegEnd(i: handler.i, p: self[handler.i].b))
                    j += 1
                }
                
                if eBuf.count > 1 {
                    eBuf.sortByAngle(center: FixVec(x, Int64(y)))
                }
                
                // find nearest scan segment for y
                var iterator = scanList.iteratorToBottom(start: y)
                var bestY = Int64.min
                var bestIndex: Int = .max
                var rangeBottom = iterator.min

                while bestY < rangeBottom && iterator.min != .min {
                    scanList.space.idsInRange(range: iterator, stop: x, ids: &candidates)
                    if !candidates.isEmpty {
                        for segIndex in candidates {
                            let seg = self[segIndex]
                            if Triangle.isClockwise(p0: seg.a, p1: FixVec(x, Int64(y)), p2: seg.b) {
                                let cy = seg.verticalIntersection(x: x)
                                if bestIndex == .max {
                                    if cy == y {
                                        if Triangle.isClockwise(p0: FixVec(x, cy), p1: seg.b, p2: seg.a) {
                                            bestIndex = segIndex
                                            bestY = cy
                                        }
                                    } else {
                                        bestIndex = segIndex
                                        bestY = cy
                                    }
                                } else {
                                    if bestY == cy {
                                        if self[bestIndex].under(seg) {
                                            bestIndex = segIndex
                                        }
                                    } else if cy == y {
                                        if seg.under(point: FixVec(x, cy)) {
                                            bestIndex = segIndex
                                            bestY = cy
                                        }
                                    } else if bestY < cy {
                                        bestIndex = segIndex
                                        bestY = cy
                                    }
                                }
                            }
                        }
                        candidates.removeAll(keepingCapacity: true)
                    }
                    
                    rangeBottom = iterator.min
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
                    if self[se.i].isVertical {
                        _ = self[se.i].addAndFill(sumCount: sumCount, fillRule: fillRule)
                    } else {
                        sumCount = self[se.i].addAndFill(sumCount: sumCount, fillRule: fillRule)
                        counts[se.i] = sumCount
                        let seg = self[se.i]
                        scanList.space.insert(segment: ScanSegment(
                            id: se.i,
                            range: seg.verticalRange,
                            stop: seg.b.x
                        ))
                    }
                }
            }
        }
    }
}

private extension Segment {
    
    var isVertical: Bool {
        a.x == b.x
    }
    
    var verticalRange: LineRange {
        if a.y > b.y {
            return LineRange(min: Int32(b.y), max: Int32(a.y))
        } else {
            return LineRange(min: Int32(a.y), max: Int32(b.y))
        }
    }
    
    func verticalIntersection(x: Int64) -> Int64 {
        let y01 = a.y - b.y
        let x01 = a.x - b.x
        let xx0 = x - a.x

        return (y01 * xx0) / x01 + a.y
    }
    
    func under(_ other: Segment) -> Bool {
        if self.a == other.a {
            return Triangle.isClockwise(p0: a, p1: other.b, p2: b)
        } else if self.b == other.b {
            return Triangle.isClockwise(p0: b, p1: a, p2: other.a)
        } else if a.x < other.a.x {
            return Triangle.isClockwise(p0: a, p1: other.a, p2: b)
        } else {
            return Triangle.isClockwise(p0: other.a, p1: other.b, p2: a)
        }
    }
    
    func under(point p: FixVec) -> Bool {
        !Triangle.isClockwise(p0: a, p1: b, p2: p)
    }
    
    mutating func addAndFill(sumCount: ShapeCount, fillRule: FillRule) -> ShapeCount {
        let newCount = sumCount.add(count)
        self.fill(sumCount: sumCount, newCount: newCount, fillRule: fillRule)
        return newCount
    }
    
    mutating func fill(sumCount: ShapeCount, newCount: ShapeCount, fillRule: FillRule) {
        let subjTop: UInt8
        let subjBottom: UInt8
        let clipTop: UInt8
        let clipBottom: UInt8
        
        switch fillRule {
        case .evenOdd:
            let sTop = 1 & newCount.subj
            let sBottom = 1 & sumCount.subj

            let cTop = 1 & newCount.clip
            let cBottom = 1 & sumCount.clip
            
            subjTop = sTop == 1 ? SegmentFill.subjectTop : 0
            subjBottom = sBottom == 1 ? SegmentFill.subjectBottom : 0
            clipTop = cTop == 1 ? SegmentFill.clipTop : 0
            clipBottom = cBottom == 1 ? SegmentFill.clipBottom : 0
        case .nonZero:
            if count.subj == 0 {
                subjTop = sumCount.subj != 0 ? SegmentFill.subjectTop : 0
                subjBottom = sumCount.subj != 0 ? SegmentFill.subjectBottom : 0
            } else {
                subjTop = newCount.subj != 0 ? SegmentFill.subjectTop : 0
                subjBottom = sumCount.subj != 0 ? SegmentFill.subjectBottom : 0
            }
            if count.clip == 0 {
                clipTop = sumCount.clip != 0 ? SegmentFill.clipTop : 0
                clipBottom = sumCount.clip != 0 ? SegmentFill.clipBottom : 0
            } else {
                clipTop = newCount.clip != 0 ? SegmentFill.clipTop : 0
                clipBottom = sumCount.clip != 0 ? SegmentFill.clipBottom : 0
            }
        }
        
        fill = subjTop | subjBottom | clipTop | clipBottom
    }
    
}

private extension Array where Element == SegEnd {
    
    mutating func sortByAngle(center: FixVec) {
        self.sort(by: {
            Triangle.isClockwise(p0: center, p1: $1.p, p2: $0.p)
        })
    }
    
}
