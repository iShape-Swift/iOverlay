//
//  PreSplitSolver.swift
//
//
//  Created by Nail Sharipov on 24.05.2024.
//

import iFixFloat

struct PreSplitSolver {
    
    static func split(solver: Solver, edges: inout [ShapeEdge]) -> Bool {
        if edges.count < solver.chunkListMaxSize {
            return SimplePreSplitSolver.split(maxRepeatCount: solver.preSplitMaxCount, edges: &edges)
        }
        
        return true
    }
}
