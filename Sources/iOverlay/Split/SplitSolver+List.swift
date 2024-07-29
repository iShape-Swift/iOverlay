//
//  SplitSolver+List.swift
//  
//
//  Created by Nail Sharipov on 23.07.2024.
//

import iFixFloat

extension SplitSolver {
    
    func listSplit(edges: inout [ShapeEdge]) -> Bool {
        var marks = [LineMark]()
        var needToFix = true
        
        while needToFix {
            needToFix = false
            
            marks.removeAll(keepingCapacity: true)
            
            let n = edges.count
            
            for i in 0..<n - 1 {
                let ei = edges[i].xSegment
                let ri = ei.boundary
                for j in i + 1..<n {
                    let ej = edges[j].xSegment
                    if ei.b.x < ej.a.x {
                        break
                    }
                    
                    guard ej.boundary.isIntersectBorderInclude(ri) else {
                        continue
                    }
                    
                    let isRound = Self.cross(i: i, j: j, ei: ei, ej: ej, marks: &marks)
                    needToFix = needToFix || isRound
                }
            }
            
            guard !marks.isEmpty else {
                return true
            }
            
            Self.apply(marks: &marks, edges: &edges)
            
            if !solver.isList(range: range.width, count: edges.count) {
                // finish with tree solver if edges is become large
                
                return self.treeSplit(edges: &edges)
            }
        }
        
        return true
    }
}
