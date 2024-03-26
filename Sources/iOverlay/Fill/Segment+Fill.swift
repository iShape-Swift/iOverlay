//
//  Segment+Fill.swift
//
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape
import iTree

private struct YGroup {
    let i: Int
    let y: Int32
}

private struct PGroup {
    let i: Int
    let p: Point
}

extension Array where Element == Segment {
    
    mutating func fill(fillRule: FillRule, solver: Solver) {
        let isList = solver == .list || solver == .auto && self.count < 1_000
        if isList {
            var store = ScanFillList(count: self.count)
            return self.solve(scanStore: &store, fillRule: fillRule)
        } else {
            var store = ScanFillTree(count: self.count)
            return self.solve(scanStore: &store, fillRule: fillRule)
        }
    }
    
    private mutating func solve<S: ScanFillStore>(scanStore: inout S, fillRule: FillRule) {
        var xBuf = [YGroup]()
        var pBuf = [PGroup]()
        
        let n = self.count
        var i = 0
        
        while i < n {
            let x = self[i].seg.a.x

            xBuf.removeAll(keepingCapacity: true)
            
            // find all new segments with same a.x
            while i < n && self[i].seg.a.x == x {
                xBuf.append(YGroup(i: i, y: self[i].seg.a.y))
                i += 1
            }
            
            if xBuf.count > 1 {
                xBuf.sort(by: { $0.y < $1.y })
            }
            
            var j = 0
            while j < xBuf.count {
                
                let y = xBuf[j].y
                
                pBuf.removeAll(keepingCapacity: true)
                
                // group new segments by same y (all segments in eBuf must have same a)
                while j < xBuf.count && xBuf[j].y == y {
                    let handler = xBuf[j]
                    pBuf.append(PGroup(i: handler.i, p: self[handler.i].seg.b))
                    j += 1
                }
                
                let p = Point(x, y)
                
                if pBuf.count > 1 {
                    pBuf.sortByAngle(center: p)
                }
                
                var sumCount = scanStore.underAndNearest(point: p, stop: x) ?? ShapeCount(subj: 0, clip: 0)

                // add new to scan
                
                for se in pBuf {
                    if self[se.i].seg.isVertical {
                        _ = self[se.i].addAndFill(sumCount: sumCount, fillRule: fillRule)
                    } else {
                        sumCount = self[se.i].addAndFill(sumCount: sumCount, fillRule: fillRule)
                        scanStore.insert(segment: CountSegment(count: sumCount, xSegment: self[se.i].seg), stop: x)
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
