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
    
}
