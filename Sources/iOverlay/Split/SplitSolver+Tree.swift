//
//  SplitSolver+Tree.swift
//
//
//  Created by Nail Sharipov on 23.07.2024.
//

extension SplitSolver {
    
    func treeSplit(edges: inout [ShapeEdge]) -> Bool {
        let layout = SpaceLayout(range: range, count: edges.count)
        var tree = SegmentTree(range: range, power: layout.power)
        
        var marks = [LineMark]()
        var needToFix = true

        while needToFix {
            needToFix = false
            
            marks.removeAll(keepingCapacity: true)

            for i in 0..<edges.count {
                let fragment = Fragment(index: i, xSegment: edges[i].xSegment)
                let anyRound = tree.intersect(this: fragment, marks: &marks)
                needToFix = anyRound || needToFix
                
                tree.insert(fragment: fragment)
            }
            
            guard !marks.isEmpty else {
                return false
            }

            tree.clear()
            
            SplitSolver.apply(needToFix: needToFix, marks: &marks, edges: &edges)
        }
        
        return false
    }
}
