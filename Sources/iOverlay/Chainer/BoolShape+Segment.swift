//
//  BoolShape+Segment.swift
//  
//
//  Created by Nail Sharipov on 21.07.2023.
//

import iShape
import iFixFloat

public extension BoolShape {
    
    func buildSegments() -> [Segment] {
        assert(edges.isAsscending())
        var segments = self.sortedSegments()
        let n = segments.count
        
        var scanList = SegmentScanList()

        var i = 0
        var s = segments[0]
        while i < n {
            let x = s.a.x

            scanList.move(x)

            // loop for same x
            repeat {
                var fill = scanList.fill(s.a.y)
                let i1 = segments.lastNodeIndex(index: i)
                
                let len = i1 - i
                if len == 1 {
                    s.isFillTop = fill
                    segments[i] = s
                    scanList.add(s)
                } else {
                    var list = [Segment](repeating: .zero, count: len)
                    for j in 0..<len {
                        let k = i + j
                        s = segments[k]
                        s.isFillTop = fill
                        segments[k] = s
                        fill = !fill
                        list[j] = s
                    }
                    
                    scanList.add(list: list)
                }
                
                i = i1
                
                if i < n {
                    s = segments[i]
                } else {
                    break
                }
            } while s.a.x == x
        }

        return segments
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
                    segments[j] = Segment(a: e.a, b: b, isFillTop: false)
                }
            } else {
                segments[i0] = Segment(a: e.a, b: e.b, isFillTop: false)
            }
        }
        
        return segments
    }
    
}

extension Array where Element == Segment {
    
    func lastNodeIndex(index: Int) -> Int {
        let a = self[index].a
        var i = index + 1
        while i < count {
            if a != self[i].a {
                return i
            }
            i += 1
        }
        return i
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
