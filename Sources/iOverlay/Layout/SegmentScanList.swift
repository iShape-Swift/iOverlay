//
//  SegmentScanList.swift
//  
//
//  Created by Nail Sharipov on 21.07.2023.
//

import iShape
import iFixFloat

struct SegmentScanList {
    
    private (set) var segments: [Segment]
    private var minBx: Int64
    
    init() {
        segments = [Segment]()
        segments.reserveCapacity(8)
        minBx = Int64.max
    }

    mutating func add(_ segment: Segment) {
        if !segment.isVertical {
            minBx = min(minBx, segment.b.x)
            segments.append(segment)
        }
    }
    
    mutating func add(list: [Segment]) {
        var n = list.count
        if list[n - 1].isVertical {
            n -= 1
        }
        
        for i in 0..<n {
            let s = list[i]
            minBx = min(minBx, s.b.x)
            segments.append(s)
        }
    }

    func fill(_ p: FixVec) -> Bool {
        var isFill = true
        for s in segments {
            if s.isUnder(p) {
                isFill = !isFill
            }
        }

        return isFill
    }
    
    mutating func clearAllBefore(_ x: Int64) {
        guard minBx <= x else {
             return
        }

        var i = segments.count - 1
        var newMin = Int64.max
        while i >= 0 {
            let sbx = segments[i].b.x
            if sbx <= x {
                segments.remove(at: i)
            } else if newMin > sbx {
                newMin = sbx
            }
            i -= 1
        }
        
        minBx = newMin
    }
    
}

private extension Segment {
    
    func isUnder(_ p: FixVec) -> Bool {
        (b - a).unsafeCrossProduct(p - a) > 0
    }
    
    var isVertical: Bool {
        a.x == b.x
    }
}
