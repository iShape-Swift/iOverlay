//
//  SimplePreSplitSolver.swift
//  
//
//  Created by Nail Sharipov on 27.05.2024.
//

import iFixFloat

struct SimplePreSplitSolver {

    static func split(maxRepeatCount: Int, edges: inout [ShapeEdge]) -> Bool {
        var marks = [LineMark]()
        var needToFix = true

        var splitCount = 0
        
        while needToFix && splitCount < maxRepeatCount {
            needToFix = false
            
            marks.removeAll(keepingCapacity: true)
            splitCount += 1
            
            let n = edges.count
            var extraSpace = 0
            
            for i in 0..<n - 1 {
                let ei = edges[i].xSegment
                for j in i + 1..<n {
                    let ej = edges[j].xSegment
                    if ei.b.x < ej.a.x {
                        break
                    }
                    
                    let test_x = ScanCrossSolver.testX(target: ei, other: ej)
                    let test_y = ScanCrossSolver.testY(target: ei, other: ej)
                    
                    if test_x || test_y {
                        continue
                    }
                    
                    guard let cross = ScanCrossSolver.preCross(target: ei, other: ej) else {
                        continue
                    }
                    
                    switch cross {
                    case .pureExact(let p):
                        extraSpace += 3
                        
                        let li = ei.a.sqrDistance(p)
                        let lj = ej.a.sqrDistance(p)
                        
                        marks.append(LineMark(index: i, length: li, point: p))
                        marks.append(LineMark(index: j, length: lj, point: p))
                    case .pureRound(let p):
                        extraSpace += 3
                        
                        let li = ei.a.sqrDistance(p)
                        let lj = ej.a.sqrDistance(p)
                        
                        marks.append(LineMark(index: i, length: li, point: p))
                        marks.append(LineMark(index: j, length: lj, point: p))
                        needToFix = true
                    case .targetEndExact(let p):
                        extraSpace += 1
                        
                        let lj = ej.a.sqrDistance(p)
                        marks.append(LineMark(index: j, length: lj, point: p))
                        
                    case .targetEndRound(let p):
                        extraSpace += 1
                        
                        let lj = ej.a.sqrDistance(p)
                        marks.append(LineMark(index: j, length: lj, point: p))
                        needToFix = true
                    case .otherEndExact(let p):
                        extraSpace += 1
                        
                        let li = ei.a.sqrDistance(p)
                        
                        marks.append(LineMark(index: i, length: li, point: p))
                    case .otherEndRound(let p):
                        extraSpace += 1
                        
                        let li = ei.a.sqrDistance(p)
                        
                        marks.append(LineMark(index: i, length: li, point: p))
                        needToFix = true
                    default:
                        assertionFailure("Can not be here")
                    }
                }
            }
            
            guard !marks.isEmpty else {
                return false
            }
            
            marks.sort(by: { $0.index < $1.index || $0.index == $1.index && $0.length < $1.length })
            
            if !needToFix {
                edges.reserveCapacity(edges.count + extraSpace)
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
        
        return needToFix
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
