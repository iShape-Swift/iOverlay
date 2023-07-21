//
//  BoolShape+Segment.swift
//  
//
//  Created by Nail Sharipov on 21.07.2023.
//

import iShape
import iFixFloat

extension BoolShape {
    
    func buildSegments() -> [Segment] {
        assert(edges.isAsscending())
        var segments = self.buildSegments()
        let n = segments.count
        
        var scanList = SegmentScanList()

        var i = 0
        while i < n {
            let s = segments[i]

            scanList.removeSegmentsEndingBeforePosition(s.a)

            if edges.isStartNode(index: i) {


            } else {



            }


            i += 1
        }

        return []
    }
    
    
    private func sortedSegments() -> [Segment] {
        assert(edges.isAsscending())
        let n = edges.count
        
        var i = 0
        var points = [FixVec]()
        var segments = [Segment](repeating: .zero, count: n)
        
        while i < n {
            let i0 = i
            let e = edges[i0]
            
            i += 1

            while i < n && e.a == edges[i].a {
                i += 1
            }
            
            if i - i0 > 1 {
                points.removeAll(keepingCapacity: true)
                for j in i0..<i {
                    points.append(edges[j].b)
                }

                points.sort(start: e.a)

                for j in i0..<i {
                    let b = points[j - i0]
                    segments[j] = Segment(a: e.a, b: b, fill: 0)
                }
            } else {
                segments[i0] = Segment(a: e.a, b: e.b, fill: 0)
            }
        }
        
        return segments
    }
    
}

extension Array where Element == Segment {
    
    func isStartNode(index: Int) -> Bool {
        guard index + 1 < count else { return false }
        return self[index].a == self[index + 1].a
    }

}

private extension Array where Element == FixVec {

    mutating func sort(start: FixVec) {
        self.sort(by: {
            if $0.x == $1.x {
                return $0.y < $1.y
            } else {
                return Triangle.isClockwise(p0: start, p1: $1, p2: $0)
            }
        })
    }
}
