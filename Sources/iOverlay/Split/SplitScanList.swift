//
//  SplitScanList.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iShape
import iFixFloat

extension LineSpace<VersionedIndex> {


    init(edges: [ShapeEdge]) {
        var yMin = Int32.max
        var yMax = Int32.min
        for edge in edges {
            if edge.xSegment.a.y > edge.xSegment.b.y {
                yMin = min(edge.xSegment.b.y, yMin)
                yMax = max(edge.xSegment.a.y, yMax)
            } else {
                yMin = min(edge.xSegment.a.y, yMin)
                yMax = max(edge.xSegment.b.y, yMax)
            }
        }
        
        let maxLevel = Int(Double(edges.count).squareRoot()).logTwo
        
        self.init(level: maxLevel, range: LineRange(min: yMin, max: yMax))
    }
}
