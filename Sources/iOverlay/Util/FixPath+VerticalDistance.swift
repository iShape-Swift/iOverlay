//
//  FixPath+VerticalDistance.swift
//  
//
//  Created by Nail Sharipov on 27.07.2023.
//

import iShape
import iFixFloat

extension FixPath {
    
    // points of holes can not have any common points with hull
    func getBottomVerticalDistance(p: FixVec) -> Int64 {
        var p0 = self[count - 1]
        var nearestY = Int64.min
        
        for pi in self {
            // any bottom and non vertical
            
            if p0.x != pi.x {
                let a: FixVec
                let b: FixVec
                
                if p0.x < pi.x {
                    a = p0
                    b = pi
                } else {
                    a = pi
                    b = p0
                }
                
                if a.x <= p.x && p.x <= b.x {
                    let y = FixPath.getVerticalIntersection(p0: a, p1: b, p: p)
                    
                    if p.y > y && y > nearestY {
                        nearestY = y
                    }
                }
            }

            p0 = pi
        }

        return p.y - nearestY
    }
    
    private static func getVerticalIntersection(p0: FixVec, p1: FixVec, p: FixVec) -> Int64 {
        let k = (p0.y - p1.y) / (p0.x - p1.x)
        let b = p0.y - k * p0.x
        
        let y = k * p.x + b

        return y
    }
    
}

