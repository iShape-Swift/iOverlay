//
//  Segment+Fill.swift
//
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape
import iTree

private struct Handler {
    let id: Int
    let b: Point
}

protocol ScanFillStore {
 
    mutating func insert(segment: CountSegment)

    mutating func underAndNearest(point p: Point) -> ShapeCount?

}

extension Array where Element == Segment {
    
    mutating func fill(fillRule: FillRule, isList: Bool) {
        if isList {
            var store = ScanFillList(count: self.count)
            return self.solve(scanStore: &store, fillRule: fillRule)
        } else {
            var store = ScanFillTree(count: self.count)
            return self.solve(scanStore: &store, fillRule: fillRule)
        }
    }
    
    private mutating func solve<S: ScanFillStore>(scanStore: inout S, fillRule: FillRule) {
        var buf = [Handler]()
        buf.reserveCapacity(4)
        
        let n = self.count
        var i = 0
        
        while i < n {
            let p = self[i].seg.a
            buf.append(Handler(id: i, b: self[i].seg.b))
            i += 1

            while i < n && self[i].seg.a == p {
                buf.append(Handler(id: i, b: self[i].seg.b))
                i += 1
            }
            
            buf.sort(by: { Triangle.isClockwise(p0: p, p1: $1.b, p2: $0.b) })

            var sumCount = scanStore.underAndNearest(point: p) ?? ShapeCount(subj: 0, clip: 0)
            
            for se in buf {
                let seg = self[se.id].seg
                if seg.isVertical {
                    _ = self[se.id].addAndFill(sumCount: sumCount, fillRule: fillRule)
                } else {
                    sumCount = self[se.id].addAndFill(sumCount: sumCount, fillRule: fillRule)
                    scanStore.insert(segment: CountSegment(count: sumCount, xSegment: seg))
                }
            }
            
            buf.removeAll(keepingCapacity: true)
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
