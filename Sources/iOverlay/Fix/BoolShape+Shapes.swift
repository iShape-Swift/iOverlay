//
//  BoolShape+Fix.swift
//  
//
//  Created by Nail Sharipov on 25.07.2023.
//

import iShape
import iFixFloat

public extension BoolShape {

    mutating func shapes() -> [FixShape] {
        _ = self.fix()
        
        let segments = self.buildSegments(fillTop: .subjectTop, fillBottom: .subjectBottom)
        
        let graph = OverlayGraph(segments: segments)
        
        let shapes = graph.partitionEvenOddShapes()
        
        return shapes
    }

    @inlinable
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
