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

    static func solve(shapeCount: Int, iPoints: [IdPoint], segments: [IdSegment]) -> HolesSolution {
        if iPoints.count < 128 {
            var scanTree = ScanHoleList(count: segments.count)
            return Self.solve(scanStore: &scanTree, shapeCount: shapeCount, iPoints: iPoints, segments: segments)
        } else {
            var scanTree = ScanHoleTree(count: segments.count)
            return Self.solve(scanStore: &scanTree, shapeCount: shapeCount, iPoints: iPoints, segments: segments)
        }
    }
    
    private static func solve<S: ScanHoleStore>(scanStore: inout S, shapeCount: Int, iPoints: [IdPoint], segments: [IdSegment]) -> HolesSolution {
        let holeCount = iPoints.count
        var holeShape = [Int](repeating: 0, count: holeCount)
        var holeCounter = [Int](repeating: 0, count: shapeCount)
       
        var i = 0
        var j = 0

        while i < iPoints.count {
            let x = iPoints[i].point.x
            
            while j < segments.count && segments[j].xSegment.a.x < x {
                let idSegment = segments[j]
                if idSegment.xSegment.b.x > x {
                    scanStore.insert(segment: idSegment, stop: x)
                }
                j += 1
            }
        
            while i < iPoints.count && iPoints[i].point.x == x {
                
                let p = iPoints[i].point
                
                // find nearest scan segment for y
                let shapeIndex = scanStore.underAndNearest(point: p, stop: x)
                let holeIndex = iPoints[i].id
                
                holeShape[holeIndex] = shapeIndex
                holeCounter[shapeIndex] += 1
                
                i += 1
            }
        }
        
        return HolesSolution(holeShape: holeShape, holeCounter: holeCounter)
    }
    
}
