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
        var yMin = Int64.max
        var yMax = Int64.min
        for edge in edges {
            if edge.a.y > edge.b.y {
                yMin = min(edge.b.y, yMin)
                yMax = max(edge.a.y, yMax)
            } else {
                yMin = min(edge.a.y, yMin)
                yMax = max(edge.b.y, yMax)
            }
        }
        
        let maxLevel = Int(Double(edges.count).squareRoot()).logTwo
        
        self.init(level: maxLevel, range: LineRange(min: Int32(yMin), max: Int32(yMax)))
    }
}
