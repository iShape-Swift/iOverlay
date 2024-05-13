//
//  SplitSolver.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iFixFloat
import iShape

struct SplitSolver {
    
    static func split(edges: [ShapeEdge], solver: Solver, range: LineRange) -> ([Segment], Bool) {
        let count = edges.count
        switch solver.strategy {
        case .list:
            let store = StoreList(edges: edges, chunkStartLength: solver.chunkStartLength)
            var solver = SplitSolverList(store: store)
            _ = solver.split(treeListThreshold: Int.max)
            return (solver.store.segments(), true)
        case .tree:
            if range.width < solver.chunkListMaxSize {
                let store = StoreList(edges: edges, chunkStartLength: solver.chunkStartLength)
                var solver = SplitSolverList(store: store)
                _ = solver.split(treeListThreshold: Int.max)
                return (solver.store.segments(), true)
            } else {
                let store = StoreTree(edges: edges, chunkStartLength: solver.chunkStartLength)
                var solver = SplitSolverTree(store: store, scanStore: ScanSplitTree(range: range, count: count))
                solver.split()
                return (solver.store.segments(), false)
            }
        case .auto:
            let listStore = StoreList(edges: edges, chunkStartLength: solver.chunkStartLength)
            if listStore.isTreeConversionRequired(chunkListMaxSize: solver.chunkListMaxSize) {
                var solver = SplitSolverTree(store: listStore.convertToTree(), scanStore: ScanSplitTree(range: range, count: count))
                solver.split()
                return (solver.store.segments(), false)
            } else {
                var listSolver = SplitSolverList(store: listStore)
                let finished = listSolver.split(treeListThreshold: solver.chunkListMaxSize)
                if finished {
                    return (listSolver.store.segments(), true)
                } else {
                    var treeSolver = SplitSolverTree(
                        store: listSolver.store.convertToTree(),
                        scanStore: ScanSplitTree(range: range, count: count << 1)
                    )
                    treeSolver.split()
                    return (treeSolver.store.segments(), false)
                }
            }
        }
    }
}
