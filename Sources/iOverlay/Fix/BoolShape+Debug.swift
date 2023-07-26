//
//  BoolShape+Debug.swift
//  
//
//  Created by Nail Sharipov on 24.07.2023.
//

import iShape
import iFixFloat

public extension BoolShape {
    
    // for debug pupose
    mutating func build() {
        _ = self.fix()
        self.sortByAngle()
    }
    
    func buildSegments() -> [Segment] {
        let n = edges.count
        var segments = [Segment](repeating: .zero, count: n)
        
        var scanList = SegmentScanList()

        var i = 0
        var e = edges[0]
        while i < n {
            let x = e.a.x

            scanList.clearAllBefore(x)

            // loop for same x
            while e.a.x == x {
                var fill = scanList.fill(e.a)
                let i1 = edges.lastNodeIndex(index: i)
                
                let len = i1 - i
                if len == 1 {
                    let s = Segment(i: i, a: e.a, b: e.b, fill: fill ? .subjectTop : .subjectBottom)
                    segments[i] = s
                    scanList.add(s)
                } else {
                    var list = [Segment](repeating: .zero, count: len)
                    for j in 0..<len {
                        let k = i + j
                        e = edges[k]
                        let s = Segment(i: k, a: e.a, b: e.b, fill: fill ? .subjectTop : .subjectBottom)
                        segments[k] = s
                        fill = !fill
                        list[j] = s
                    }
                    
                    scanList.add(list: list)
                }
                
                i = i1
                
                if i < n {
                    e = edges[i]
                } else {
                    break
                }
            }
        }

        return segments
    }
}
