//
//  BoolShape+Fix.swift
//  
//
//  Created by Nail Sharipov on 25.07.2023.
//

import iShape
import iFixFloat

public extension BoolShape {
    
    mutating func build() {
        _ = self.fix()
        self.sortByAngle()
    }
    
    mutating func shapes() -> [FixShape] {
        self.build()
        
        let segments = self.buildSegments()
        
        let graph = OverlayGraph(segments: segments)
        
        let shapes = graph.partitionEvenOddShapes()
        
        return shapes
    }
    
}
