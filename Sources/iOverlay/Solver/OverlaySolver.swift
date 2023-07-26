//
//  OverlaySolver.swift
//  
//
//  Created by Nail Sharipov on 21.07.2023.
//

import iFixFloat

public struct OverlaySolution {
//    let segments: [Segment]
    
    // union
    // xor
    // intersect
    // difference
}

public struct OverlaySolver {

    public static func overlay(subject: inout BoolShape, clip: inout BoolShape) -> OverlaySolution {
        cross(subject: &subject, clip: &clip)
        
//        let subSegments = subject.buildSegments(fillTop: .subjectTop, fillBottom: .subjectBottom)
//        let clipSegments = clip.buildSegments(fillTop: .clipTop, fillBottom: .clipBottom)

        return OverlaySolution()
    }
    
    
    private static func cross(subject: inout BoolShape, clip: inout BoolShape) {
        
    }

    private static func merge(subject: [Segment], clip: [Segment]) -> [Segment] {
        // both array are sorted
        
        return []
    }
    
}
