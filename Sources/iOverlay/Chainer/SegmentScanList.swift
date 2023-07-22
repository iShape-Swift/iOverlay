//
//  SegmentScanList.swift
//  
//
//  Created by Nail Sharipov on 21.07.2023.
//

import iShape
import iFixFloat

struct SegmentScanList {
    
    private static let emptySegment = Segment(a: FixVec(.max, .max), b: FixVec(.max, .max), isFillTop: false)
    
    private (set) var segments: [Segment]
    private var xPos: Int64
    private var xbMin: Int64
    private var xCount: Int
    private var last: Segment
    
    init() {
        segments = [Segment]()
        segments.reserveCapacity(8)
        xCount = 0
        xPos = Int64.min
        xbMin = Int64.max
        last = SegmentScanList.emptySegment
    }

    mutating func add(_ segment: Segment) {
        if segment.isParallelOY {
            last = segment
        } else {
            if segment.a.x != segment.b.x {
                for s in segments where s.b == segment.a {
                    xCount += 1
                    break
                }
            }

            xbMin = min(xbMin, segment.b.x)
            segments.append(segment)
            last = SegmentScanList.emptySegment
        }
    }
    
    mutating func add(list: [Segment]) {
        let last = list.lastElement

        let n: Int
        
        if last.isParallelOY {
            self.last = last
            n = list.count - 1
        } else {
            n = list.count
        }
        
        let a = list[0].a
        for s in segments where s.b == a {
            xCount += n
            break
        }
        
        for i in 0..<n {
            let s = list[i]
            xbMin = min(xbMin, s.b.x)
            segments.append(s)
        }
    }

    func fill(_ y: Int64) -> Bool {
        guard last.b.y != y else {
            return last.isFillTop
        }

        var n = 0
        let p = FixVec(xPos, y)
        for s in segments {
            if s.a.x < xPos && xPos < s.b.x {
                if s.isUnder(p) {
                    n += 1
                }
            }
        }
        
        n += xCount
        
        let isFillTop = n % 2 == 0
        
        return isFillTop
    }
    
    mutating func move(_ x: Int64) {
        xPos = x
        xCount = 0
        last = SegmentScanList.emptySegment
        guard xbMin < x else {
             return
        }

        var i = segments.count - 1
        var minBx = Int64.max
        while i >= 0 {
            let sbx = segments[i].b.x
            if sbx < x {
                segments.remove(at: i)
            } else if minBx > sbx {
                minBx = sbx
            }
            i -= 1
        }
        
        xbMin = minBx
    }
    
}

private extension Segment {
    
    func isUnder(_ p: FixVec) -> Bool {
        let vs = b - a
        let vp = p - a

        return vs.unsafeCrossProduct(vp) > 0
    }
    
    var isParallelOY: Bool {
        a.x == b.x
    }

}

private extension Array where Element == Segment {
 
    var lastElement: Segment {
        self[count - 1]
    }
    
}
