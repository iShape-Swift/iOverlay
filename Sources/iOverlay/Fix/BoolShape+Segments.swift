//
//  BoolShape+Debug.swift
//  
//
//  Created by Nail Sharipov on 24.07.2023.
//

import iShape
import iFixFloat

public extension BoolShape {

    func buildSegments(fillTop: FillMask, fillBottom: FillMask) -> [Segment] {
        let n = edges.count
        var segments = [Segment](repeating: .zero, count: n)
        for i in 0..<n {
            let e = edges[i]
            segments[i] = Segment(i: i, a: e.a, b: e.b, fill: 0)
        }
        
        Self.fill(segments: &segments, fillTop: fillTop, fillBottom: fillBottom)
        
        return segments
    }
}
