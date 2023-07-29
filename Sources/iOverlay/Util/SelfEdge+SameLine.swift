//
//  SelfEdge+SameLine.swift
//  
//
//  Created by Nail Sharipov on 28.07.2023.
//

import iFixFloat
import iShape

extension SelfEdge {
    
    @inlinable
    func isNotSameLine(_ point: FixVec) -> Bool {
        Triangle.isNotLine(p0: a, p1: b, p2: point)
    }
    
}
