//
//  FixPath+VerticalDistanceMarker.swift
//  
//
//  Created by Nail Sharipov on 27.07.2023.
//

import iShape
import iFixFloat

struct VerticalDistanceMarker {
    
    static let empty = VerticalDistanceMarker(start: .emptyMin, end: .emptyMin)
    
    let start: FixVec
    let end: FixVec
    
    func isBetter(_ other: VerticalDistanceMarker) -> Bool {
        guard other.start != .emptyMin else {
            return true
        }
        // take which higher
        if start.y >= other.start.y {
            let isNotEqual = start.y != other.start.y
            let isNearByRotate = Triangle.isClockwise(p0: start, p1: end, p2: other.end)
            return isNotEqual || isNearByRotate
        } else {
            return false
        }
    }

}

extension FixPath {
    
    // points of holes can not have any common points with hull
    func getVerticalMarker(p: FixVec) -> VerticalDistanceMarker {
        var p0 = self[count - 1]
        var bestMark = VerticalDistanceMarker.empty
        
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
                    
                    if y < p.y { // take only bottom
                        let newMark = VerticalDistanceMarker(start: FixVec(p.x, y), end: b)
                        if newMark.isBetter(bestMark) {
                            bestMark = newMark
                        }
                    }
                }
            }

            p0 = pi
        }

        return bestMark
    }
    
    private static func getVerticalIntersection(p0: FixVec, p1: FixVec, p: FixVec) -> Int64 {
        let k = (p0.y - p1.y) / (p0.x - p1.x)
        let b = p0.y - k * p0.x
        
        let y = k * p.x + b

        return y
    }
    
}

