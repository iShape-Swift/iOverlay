//
//  PreSplitSolver.swift
//
//
//  Created by Nail Sharipov on 24.05.2024.
//

import iFixFloat

struct SplitSolver {

    let solver: Solver
    let range: LineRange
    
    init(solver: Solver, range: LineRange) {
        self.solver = solver
        self.range = range
    }
    
    func split(edges: inout [ShapeEdge]) -> Bool {
        let isList = solver.isList(range: range.width, count: edges.count)
        
        if isList {
            return self.listSplit(edges: &edges)
        } else {
            return self.treeSplit(edges: &edges)
        }
    }

    static func cross(i: Int, j: Int, ei: XSegment, ej: XSegment, marks: inout[LineMark]) -> Bool {
        guard let cross = CrossSolver.cross(target: ei, other: ej) else {
            return false
        }
        
        switch cross.type {
        case .pure:
            let li = ei.a.sqrDistance(cross.point)
            let lj = ej.a.sqrDistance(cross.point)
            
            marks.append(LineMark(index: i, length: li, point: cross.point))
            marks.append(LineMark(index: j, length: lj, point: cross.point))
        case .targetEnd:
            let lj = ej.a.sqrDistance(cross.point)
            marks.append(LineMark(index: j, length: lj, point: cross.point))
        case .otherEnd:
            let li = ei.a.sqrDistance(cross.point)
            
            marks.append(LineMark(index: i, length: li, point: cross.point))
        }
        
        return cross.isRound
    }
    
    static func apply(needToFix: Bool, marks: inout [LineMark], edges: inout [ShapeEdge]) {
        marks.sort(by: { $0.index < $1.index || $0.index == $1.index && $0.length < $1.length })
        
        if !needToFix {
            edges.reserveCapacity(edges.count + 4 * marks.count)
        }
        
        var i = 0
        while i < marks.count {
            let i0 = i
            let index = marks[i].index
            while i < marks.count && marks[i].index == index {
                i += 1
            }
            
            let e0 = edges[index]
            var p = marks[i0].point
            var l = marks[i0].length
            edges[index] = ShapeEdge.createAndValidate(a: e0.xSegment.a, b: p, count: e0.count)
            
            var j = i0 + 1
            while j < i {
                let mj = marks[j]
                if l != mj.length {
                    let e = ShapeEdge.createAndValidate(a: p, b: mj.point, count: e0.count)
                    edges.append(e)
                    
                    p = mj.point
                    l = mj.length
                }
                j += 1
            }
            edges.append(ShapeEdge.createAndValidate(a: p, b: e0.xSegment.b, count: e0.count))
        }
        
        edges.sort(by: { $0.xSegment < $1.xSegment })
        
        edges.merge()
    }
}

private extension [ShapeEdge] {
    mutating func merge() {
        var i = 0
        while i < self.count {
            let ei = self[i]
            var count = ei.count
            var isModified = false
            while i + 1 < self.count && ei.xSegment == self[i + 1].xSegment {
                let c = self.remove(at: i + 1).count
                count = count.add(c)
                isModified = true
            }
            
            if isModified {
                self[i].count = count
            }
            
            i += 1
        }
    }
}
