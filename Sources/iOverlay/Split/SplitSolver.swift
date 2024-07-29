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
        case .overlap:
            let overlapResult = CrossSolver.overlap(target: ei, other: ej)
            if overlapResult.isTargetA {
                let lj = ej.a.sqrDistance(ei.a)
                marks.append(LineMark(index: j, length: lj, point: ei.a))
            }
            if overlapResult.isTargetB {
                let lj = ej.a.sqrDistance(ei.b)
                marks.append(LineMark(index: j, length: lj, point: ei.b))
            }
            if overlapResult.isOtherA {
                let li = ei.a.sqrDistance(ej.a)
                marks.append(LineMark(index: i, length: li, point: ej.a))
            }
            if overlapResult.isOtherB {
                let li = ei.a.sqrDistance(ej.b)
                marks.append(LineMark(index: i, length: li, point: ej.b))
            }
        }
        
        return cross.isRound
    }
    
    static func apply(marks: inout [LineMark], edges: inout [ShapeEdge]) {
        marks.sort(by: {
            $0.index < $1.index ||
            $0.index == $1.index && ($0.length < $1.length || $0.length == $1.length && $0.point < $1.point)
        })
        
        var i = 0
        while i < marks.count {
            let i0 = i
            let index = marks[i].index
            while i < marks.count && marks[i].index == index {
                i += 1
            }
            
            if i0 + 1 == i {
                let e0 = edges[index]
                let p = marks[i0].point
                edges[index] = ShapeEdge.createAndValidate(a: e0.xSegment.a, b: p, count: e0.count)
                edges.append(ShapeEdge.createAndValidate(a: p, b: e0.xSegment.b, count: e0.count))
            } else {
                Self.multiSplitEdge(marks: &marks[i0..<i], edges: &edges)
            }
        }
        
        edges.sort(by: { $0.xSegment < $1.xSegment })
        
        edges.mergeIfNeeded()
    }
    
    private static func multiSplitEdge(marks: inout ArraySlice<LineMark>, edges: inout [ShapeEdge]) {
        let index = marks[marks.startIndex].index
        var p = marks[marks.startIndex].point
        var l = marks[marks.startIndex].length

        let e0 = edges[index]

        edges[index] = ShapeEdge.createAndValidate(a: e0.xSegment.a, b: p, count: e0.count)

        var j = marks.startIndex
        while j < marks.endIndex {
            let mj = marks[j]
            if l != mj.length || p != mj.point {
                edges.append(ShapeEdge.createAndValidate(a: p, b: mj.point, count: e0.count))
                p = mj.point
                l = mj.length
            }
            j += 1
        }
        edges.append(ShapeEdge.createAndValidate(a: p, b: e0.xSegment.b, count: e0.count))
    }
    
}
