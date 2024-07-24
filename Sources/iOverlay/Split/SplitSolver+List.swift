//
//  SplitSolver+List.swift
//  
//
//  Created by Nail Sharipov on 23.07.2024.
//

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
                for j in i + 1..<n {
                    let ej = edges[j].xSegment
                    if ei.b.x < ej.a.x {
                        break
                    }
                    
                    if ei.isBoundaryNotCross(ej) {
                        continue
                    }
                    
                    let isRound = Self.cross(i: i, j: j, ei: ei, ej: ej, marks: &marks)
                    needToFix = needToFix || isRound
                }
            }
            
            guard !marks.isEmpty else {
                return true
            }
            
            Self.apply(needToFix: needToFix, marks: &marks, edges: &edges)
            
            if !solver.isList(range: range.width, count: edges.count) {
                // finish with tree solver if edges is become large
                
                return self.treeSplit(edges: &edges)
            }
        }
        
        return true
    }
}

private extension XSegment {
    
    func isBoundaryNotCross(_ other: XSegment) -> Bool {
        Self.testY(target: self, other: other) || Self.testX(target: self, other: other)
    }
    
    private static func testX(target: XSegment, other: XSegment) -> Bool {
         // MARK: a < b by design
        let testX =
        target.a.x > other.a.x && target.a.x > other.b.x ||
        other.a.x > target.a.x && other.a.x > target.b.x
        
        return testX
    }
    
    private static func testY(target: XSegment, other: XSegment) -> Bool {
        let testY =
        // a > all other
        target.a.y > other.a.y && target.a.y > other.b.y &&
        // b > all other
        target.b.y > other.a.y && target.b.y > other.b.y ||
        // a < all other
        target.a.y < other.a.y && target.a.y < other.b.y &&
        // b < all other
        target.b.y < other.a.y && target.b.y < other.b.y
        
        return testY
    }

}
