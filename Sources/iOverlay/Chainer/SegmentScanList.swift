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
    private var xbMin: Int64
    
    init() {
        segments = [Segment]()
        segments.reserveCapacity(8)
        xbMin = Int64.max
    }

    mutating func add(_ segment: Segment) {
        if !segment.isParallelOY {
            xbMin = min(xbMin, segment.b.x)
            segments.append(segment)
        }
    }
    
    mutating func add(list: [Segment]) {
        let last = list.lastElement

        let n = last.isParallelOY ? list.count - 1 : list.count
        
        for i in 0..<n {
            let s = list[i]
            xbMin = min(xbMin, s.b.x)
            segments.append(s)
        }
    }

    func fill(_ p: FixVec) -> Bool {
        var n = 0
        for s in segments {
            if s.isUnder(p) {
                n += 1
            }
        }
        
        let isFillTop = n % 2 == 0
        
        return isFillTop
    }
    
    mutating func move(_ x: Int64) {
        guard xbMin <= x else {
             return
        }

        var i = segments.count - 1
        var minBx = Int64.max
        while i >= 0 {
            let sbx = segments[i].b.x
            if sbx <= x {
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
