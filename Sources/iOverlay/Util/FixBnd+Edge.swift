//
//  FixBnd+Edge.swift
//  
//
//  Created by Nail Sharipov on 31.07.2023.
//

import iShape
import iFixFloat

extension FixBnd {
    
    init(minX: Int64, edges: [SelfEdge]) {
        var maxX = Int64.min
        var minY = Int64.max
        var maxY = Int64.min

        for edge in edges {
            let abMaxX = Swift.max(edge.a.x, edge.b.x)
            let abMinY = Swift.min(edge.a.y, edge.b.y)
            let abMaxY = Swift.max(edge.a.y, edge.b.y)
            
            maxX = Swift.max(maxX, abMaxX)
            minY = Swift.min(minY, abMinY)
            maxY = Swift.max(maxY, abMaxY)
        }

        self.init(min: FixVec(minX, minY), max: FixVec(maxX, maxY))
    }
    
    @inlinable
    init(edge: SelfEdge) {
        let minX = edge.a.x
        let maxX = edge.b.x
        let minY: Int64
        let maxY: Int64
        if edge.a.y < edge.b.y {
            minY = edge.a.y
            maxY = edge.b.y
        } else {
            minY = edge.b.y
            maxY = edge.a.y
        }
        self.init(min: FixVec(minX, minY), max: FixVec(maxX, maxY))
    }
    
}
