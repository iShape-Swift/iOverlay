//
//  SquareRange.swift
//  
//
//  Created by Nail Sharipov on 25.01.2024.
//

import iFixFloat
import iShape

public struct SquareRange {
    
    public let xMin: Int32
    public let xMax: Int32
    public let yMin: Int32
    public let yMax: Int32
    
    var xRange: LineRange {
        LineRange(min: xMin, max: xMax)
    }
    
    var yRange: LineRange {
        LineRange(min: yMin, max: yMax)
    }
    
    public init(xMin: Int32, xMax: Int32, yMin: Int32, yMax: Int32) {
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax
    }
    
    public init(points: FixPath) {
        let p0 = points[0]
        var xMin = Int32(p0.x)
        var xMax = Int32(p0.x)
        var yMin = Int32(p0.y)
        var yMax = Int32(p0.y)

        for i in 1..<points.count {
            let p = points[i]
            let x = Int32(p.x)
            let y = Int32(p.y)

            xMin = min(xMin, x)
            xMax = max(xMax, x)
            yMin = min(yMin, y)
            yMax = max(yMax, y)
        }
        
        self.xMin = xMin
        self.xMax = xMax
        self.yMin = yMin
        self.yMax = yMax
    }
}
//3
