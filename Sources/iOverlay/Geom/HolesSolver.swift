//
//  HolesSolver.swift
//
//
//  Created by Nail Sharipov on 31.01.2024.
//

import iFixFloat
import iTree

struct HolesSolution {
    let holeShape: [Int]
    let holeCounter: [Int]
}

struct HolesSolver {

    static func solve(shapeCount: Int, iPoints: [IdPoint], floors: [Floor]) -> HolesSolution {
        let holeCount = iPoints.count
        
        let capacity = Int(4 * Double(shapeCount).squareRoot())
        
        var scanTree = RBTree(empty: Floor(id: .max, a: .zero, b: .zero), capacity: capacity)

        var holeShape = [Int](repeating: 0, count: holeCount)
        var holeCounter = [Int](repeating: 0, count: shapeCount)
       
        var i = 0
        var j = 0

        while i < iPoints.count {
            let x = iPoints[i].point.x
            
            while j < floors.count && floors[j].seg.a.x < x {
                let floor = floors[j]
                if floor.seg.b.x > x {
                    scanTree.insert(value: floor)
                }
                j += 1
            }
        
            while i < iPoints.count && iPoints[i].point.x == x {
                
                let p = iPoints[i].point
                
                // find nearest scan segment for y
                let shapeIndex = scanTree.underAndNearest(point: p, stop: x)
                let holeIndex = iPoints[i].id
                
                holeShape[holeIndex] = shapeIndex
                holeCounter[shapeIndex] += 1
                
                i += 1
            }
        }
        
        return HolesSolution(holeShape: holeShape, holeCounter: holeCounter)
    }
    
}
