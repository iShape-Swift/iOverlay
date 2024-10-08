//
//  SplitSolver+Tree.swift
//
//
//  Created by Nail Sharipov on 23.07.2024.
//

extension SplitSolver {
    
    func treeSplit(edges: inout [Segment]) -> Bool {
        let verRange = edges.verRange()
        let height = Int(verRange.width)
        
        if height < SpaceLayout.minHeight {
            return self.listSplit(edges: &edges)
        }
        
        let layout = SpaceLayout(height: height, count: edges.count)
        
        if layout.isFragmentationRequired(edges: edges) {
            self.simple(verRange: verRange, layout: layout, edges: &edges)
        } else {
            self.complex(verRange: verRange, layout: layout, edges: &edges)
        }
        
        return false
    }
    
    private func simple(verRange: LineRange, layout: SpaceLayout, edges: inout [Segment]) {
        var tree = SegmentTree(range: verRange, power: layout.power, radius: 0)
        
        var marks = [LineMark]()
        
        var needToFix = true
        var iter = 0

        while needToFix && edges.count > 2 {
            needToFix = false
            
            tree.radius = self.solver.radius(iteration: iter)
            
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
            
            SplitSolver.apply(marks: &marks, edges: &edges)

            marks.removeAll(keepingCapacity: true)
            
            iter += 1
        }
    }

    private func complex(verRange: LineRange, layout: SpaceLayout, edges: inout [Segment]) {
        var tree = SegmentTree(range: verRange, power: layout.power, radius: 0)
        
        var marks = [LineMark]()
        var needToFix = true
        var fragments = [Fragment]()
        fragments.reserveCapacity(2 * edges.count)
        
        var iter = 0
        
        while needToFix && edges.count > 2 {
            needToFix = false
            
            for i in 0..<edges.count {
                layout.breakIntoFragments(index: i, xSegment: edges[i].xSegment, buffer: &fragments)
            }
            
            guard 100 * fragments.count > 110 * edges.count else {
                // we can switch to simple solution
                self.simple(verRange: verRange, layout: layout, edges: &edges)
                return
            }

            tree.radius = self.solver.radius(iteration: iter)
            
            for fragment in fragments {
                let anyRound = tree.intersect(this: fragment, marks: &marks)
                needToFix = anyRound || needToFix
                
                tree.insert(fragment: fragment)
            }
            
            guard !marks.isEmpty else {
                return
            }
            
            fragments.removeAll(keepingCapacity: true)
            tree.clear()
            
            SplitSolver.apply(marks: &marks, edges: &edges)
            
            marks.removeAll(keepingCapacity: true)
            
            iter += 1
        }
    }
}

private extension Array where Element == Segment {
    func verRange() -> LineRange {
        var minY: Int32 = self[0].xSegment.a.y
        var maxY: Int32 = minY
        
        for edge in self {
            minY = Swift.min(minY, edge.xSegment.a.y)
            maxY = Swift.max(maxY, edge.xSegment.a.y)
            minY = Swift.min(minY, edge.xSegment.b.y)
            maxY = Swift.max(maxY, edge.xSegment.b.y)
        }
        
        return LineRange(min: minY, max: maxY)
    }
}
