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
            return Self.singleSplit(maxRepeatCount: solver.preSplitMaxCount, edges: &edges)
        }
        
        return true
    }
    
    static func cross(i: Int, j: Int, ei: XSegment, ej: XSegment, needToFix : inout Bool, marks: inout[LineMark]) {
        guard let cross = ScanCrossSolver.preCross(target: ei, other: ej) else {
            return
        }
        
        switch cross {
        case .pureExact(let p):
            let li = ei.a.sqrDistance(p)
            let lj = ej.a.sqrDistance(p)
            
            marks.append(LineMark(index: i, length: li, point: p))
            marks.append(LineMark(index: j, length: lj, point: p))
        case .pureRound(let p):
            let li = ei.a.sqrDistance(p)
            let lj = ej.a.sqrDistance(p)
            
            marks.append(LineMark(index: i, length: li, point: p))
            marks.append(LineMark(index: j, length: lj, point: p))
            needToFix = true
        case .targetEndExact(let p):
            let lj = ej.a.sqrDistance(p)
            marks.append(LineMark(index: j, length: lj, point: p))
        case .targetEndRound(let p):
            let lj = ej.a.sqrDistance(p)
            
            marks.append(LineMark(index: j, length: lj, point: p))
            needToFix = true
        case .otherEndExact(let p):
            let li = ei.a.sqrDistance(p)
            
            marks.append(LineMark(index: i, length: li, point: p))
        case .otherEndRound(let p):
            let li = ei.a.sqrDistance(p)
            
            marks.append(LineMark(index: i, length: li, point: p))
            needToFix = true
        default:
            assertionFailure("Can not be here")
        }
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
            
            if isModified || count.isEmpty {
                if count.isEmpty {
                    self.remove(at: i)
                } else {
                    self[i].count = count
                    i += 1
                }
            } else {
                i += 1
            }
        }
    }
    
}
