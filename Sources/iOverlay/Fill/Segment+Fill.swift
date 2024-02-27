//
//  Segment+Fill.swift
//
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape
import iTree

private struct XGroup {
    let i: Int
    let x: Int32
}

private struct PGroup {
    let i: Int
    let p: Point
}

public extension Array where Element == Segment {
    
    mutating func fill(fillRule: FillRule) {
        var xBuf = [XGroup]()
        var pBuf = [PGroup]()
        
        let capacity = Int(3 * Double(self.count).squareRoot())
        #if DEBUG
        var scanTree = RBTree(empty: TreeFillSegment(index: .max, count: .init(subj: 0, clip: 0), xSegment: XSegment(a: .zero, b: .zero)), capacity: capacity)
        #else
        var scanTree = RBTree(empty: TreeFillSegment(count: .init(subj: 0, clip: 0), xSegment: XSegment(a: .zero, b: .zero)), capacity: capacity)
        #endif
        
        let n = self.count
        var i = 0
        
        while i < n {
            let x = self[i].seg.a.x

            xBuf.removeAll(keepingCapacity: true)
            
            // find all new segments with same a.x
            while i < n && self[i].seg.a.x == x {
                xBuf.append(XGroup(i: i, x: self[i].seg.a.y))
                i += 1
            }
            
            if xBuf.count > 1 {
                // sort all by a.y
                xBuf.sort(by: { $0.x < $1.x })
            }
            
            // find nearest segment from scan list for all new segments
            
            var j = 0
            while j < xBuf.count {
                
                let y = xBuf[j].x
                
                pBuf.removeAll(keepingCapacity: true)
                
                // group new segments by same y (all segments in eBuf must have same a)
                while j < xBuf.count && xBuf[j].x == y {
                    let handler = xBuf[j]
                    pBuf.append(PGroup(i: handler.i, p: self[handler.i].seg.b))
                    j += 1
                }
                
                let p = Point(x, y)
                
                if pBuf.count > 1 {
                    pBuf.sortByAngle(center: p)
                }
                
                var sumCount = scanTree.underAndNearest(point: p, stop: x)

                // add new to scan
                
                for se in pBuf {
                    if self[se.i].seg.isVertical {
                        _ = self[se.i].addAndFill(sumCount: sumCount, fillRule: fillRule)
                    } else {
                        sumCount = self[se.i].addAndFill(sumCount: sumCount, fillRule: fillRule)
                        #if DEBUG
                        scanTree.insert(value: TreeFillSegment(index: se.i, count: sumCount, xSegment: self[se.i].seg))
                        #else
                        scanTree.insert(value: TreeFillSegment(count: sumCount, xSegment: self[se.i].seg))
                        #endif
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
        
        let subjTop = isSubjTop ? SegmentFill.subjTop : 0
        let subjBottom = isSubjBottom ? SegmentFill.subjBottom : 0
        let clipTop = isClipTop ? SegmentFill.clipTop : 0
        let clipBottom = isClipBottom ? SegmentFill.clipBottom : 0
        
        fill = subjTop | subjBottom | clipTop | clipBottom
    }
    
}

private extension Array where Element == PGroup {
    
    mutating func sortByAngle(center: Point) {
        let c = FixVec(center)
        self.sort(by: {
            Triangle.isClockwise(p0: c, p1: FixVec($1.p), p2: FixVec($0.p))
        })
    }
    
}
