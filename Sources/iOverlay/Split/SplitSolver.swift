//
//  ShapeEdge+Split.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iFixFloat
import iShape

struct SplitSolver {
    
    static func split(edges: [ShapeEdge], solver: Solver, range: LineRange) -> ([Segment], Bool) {
        switch solver.strategy {
        case .list:
            let store = StoreList(edges: edges, chunkStartLength: solver.chunkStartLength)
            var solver = SplitSolverList(store: store)
            _ = solver.split(treeListThreshold: Int.max)
            return (solver.store.segments(), true)
        case .tree:
            let store = StoreTree(edges: edges, chunkStartLength: solver.chunkStartLength)
            var solver = SplitSolverTree(store: store, scanStore: ScanSplitTree(range: range, count: edges.count))
            solver.split()
            return (solver.store.segments(), false)
        case .auto:
            let listStore = StoreList(edges: edges, chunkStartLength: solver.chunkStartLength)
            if range.width < solver.chunkListMaxSize {
                var solver = SplitSolverList(store: listStore)
                _ = solver.split(treeListThreshold: Int.max)
                return (solver.store.segments(), true)
            } else if listStore.isLarge(chunkListMaxSize: solver.chunkListMaxSize) {
                var solver = SplitSolverTree(store: listStore.convertToTree(), scanStore: ScanSplitTree(range: range, count: edges.count))
                solver.split()
                return (solver.store.segments(), false)
            } else {
                var listSolver = SplitSolverList(store: listStore)
                let finished = listSolver.split(treeListThreshold: Int.max)
                if finished {
                    return (listSolver.store.segments(), true)
                } else {
                    var treeSolver = SplitSolverTree(
                        store: listSolver.store.convertToTree(),
                        scanStore: ScanSplitTree(range: range, count: edges.count)
                    )
                    treeSolver.split()
                    return (treeSolver.store.segments(), false)
                }
            }
        }
    }
}

extension ShapeEdge {
    static func createAndValidate(a: Point, b: Point, count: ShapeCount) -> ShapeEdge {
        if a < b {
            ShapeEdge(xSegment: XSegment(a: a, b: b), count: count)
        } else {
            ShapeEdge(xSegment: XSegment(a: b, b: a), count: count.invert())
        }
    }
}
