//
//  SimplePreSplitSolver.swift
//  
//
//  Created by Nail Sharipov on 27.05.2024.
//

import iFixFloat

extension PreSplitSolver {

    static func singleSplit(maxRepeatCount: Int, edges: inout [ShapeEdge]) -> Bool {
        var marks = [LineMark]()
        var needToFix = true

        var splitCount = 0
        
        while needToFix && splitCount < maxRepeatCount {
            needToFix = false
            
            marks.removeAll(keepingCapacity: true)
            splitCount += 1
            
            let n = edges.count
            
            for i in 0..<n - 1 {
                let ei = edges[i].xSegment
                for j in i + 1..<n {
                    let ej = edges[j].xSegment
                    if ei.b.x < ej.a.x {
                        break
                    }
                    
                    let test_x = ScanCrossSolver.testX(target: ei, other: ej)
                    let test_y = ScanCrossSolver.testY(target: ei, other: ej)
                    
                    if test_x || test_y {
                        continue
                    }
                    
                    Self.cross(i: i, j: j, ei: ei, ej: ej, needToFix: &needToFix, marks: &marks)
                }
            }
            
            guard !marks.isEmpty else {
                return false
            }

            Self.apply(needToFix: needToFix, marks: &marks, edges: &edges)
        }
        
        return needToFix
    }
}
