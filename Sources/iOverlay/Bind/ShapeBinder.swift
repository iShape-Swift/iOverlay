//
//  ShapeBinder.swift
//
//
//  Created by Nail Sharipov on 31.01.2024.
//

import iFixFloat
import iTree

struct HoleSolution {
    let parentForChild: [Int]
    let childrenCountForParent: [Int]
}

struct ShapeBinder {

    static func solve(shapeCount: Int, iPoints: [IdPoint], segments: [IdSegment]) -> HoleSolution {
        if iPoints.count < 128 {
            var scanList = ScanBindList(count: segments.count)
            return Self.solve(scanStore: &scanList, shapeCount: shapeCount, iPoints: iPoints, segments: segments)
        } else {
            var scanTree = ScanBindTree(count: segments.count)
            return Self.solve(scanStore: &scanTree, shapeCount: shapeCount, iPoints: iPoints, segments: segments)
        }
    }
    
    private static func solve<S: ScanBindStore>(scanStore: inout S, shapeCount: Int, iPoints: [IdPoint], segments: [IdSegment]) -> HoleSolution {
        let childrenCount = iPoints.count
        var parentForChild = [Int](repeating: 0, count: childrenCount)
        var childrenCountForParent = [Int](repeating: 0, count: shapeCount)
       
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

                let shapeIndex = scanStore.underAndNearest(point: p, stop: x)
                let childIndex = iPoints[i].id
                
                parentForChild[childIndex] = shapeIndex
                childrenCountForParent[shapeIndex] += 1
                
                i += 1
            }
        }
        
        return HoleSolution(parentForChild: parentForChild, childrenCountForParent: childrenCountForParent)
    }
    
}
