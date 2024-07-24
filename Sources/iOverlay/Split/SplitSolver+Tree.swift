//
//  SplitSolver+Tree.swift
//
//
//  Created by Nail Sharipov on 23.07.2024.
//

extension SplitSolver {
    
    func treeSplit(edges: inout [ShapeEdge]) -> Bool {
        let layout = SpaceLayout(range: range, count: edges.count)
        
        if layout.isFragmentationRequired(edges: edges) {
            self.simple(layout: layout, edges: &edges)
        } else {
            self.complex(layout: layout, edges: &edges)
        }
        
        return false
    }
    
    private func simple(layout: SpaceLayout, edges: inout [ShapeEdge]) {
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
                return
            }

            tree.clear()
            
            SplitSolver.apply(needToFix: needToFix, marks: &marks, edges: &edges)
        }
    }

    private func complex(layout: SpaceLayout, edges: inout [ShapeEdge]) {
        var tree = SegmentTree(range: range, power: layout.power)
        
        var marks = [LineMark]()
        var needToFix = true
        var fragments = [Fragment]()
        fragments.reserveCapacity(2 * edges.count)

        while needToFix {
            needToFix = false

            marks.removeAll(keepingCapacity: true)
            fragments.removeAll(keepingCapacity: true)
            
            for i in 0..<edges.count {
                layout.breakIntoFragments(index: i, xSegment: edges[i].xSegment, buffer: &fragments)
            }
            
            guard 100 * fragments.count > 110 * edges.count else {
                // we can switch to simple solution
                self.simple(layout: layout, edges: &edges)
                return
            }

            
            for fragment in fragments {
                let anyRound = tree.intersect(this: fragment, marks: &marks)
                needToFix = anyRound || needToFix
                
                tree.insert(fragment: fragment)
            }
            
            guard !marks.isEmpty else {
                return
            }

            tree.clear()
            
            SplitSolver.apply(needToFix: needToFix, marks: &marks, edges: &edges)
        }
    }
}
