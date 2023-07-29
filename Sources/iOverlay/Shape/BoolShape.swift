//
//  BoolShape.swift
//  
//
//  Created by Nail Sharipov on 20.07.2023.
//

import iFixFloat
import iShape

@usableFromInline
enum BoolShapeState {
    case dirty
    case sortedByLength
    case sortedByAngle
}

public struct BoolShape {
    
    public internal (set) var edges: [SelfEdge]
    private var state: BoolShapeState
    
    public init(capacity: Int) {
        edges = [SelfEdge]()
        edges.reserveCapacity(capacity)
        state = .dirty
    }

    public mutating func add(path: [FixVec]) {
        guard path.count > 2 else { return }
        let clean = path.removedDegenerates()
        guard clean.count > 2 else { return }
        
        state = .dirty
        edges.append(contentsOf: clean.edges)
    }

    mutating func fix() -> Bool {
        if state != .sortedByLength {
            edges.sort(by: { $0.isLess($1) })
        }
        
        edges.eliminateSame()
        
        assert(edges.isAsscending())

        let splitResult = edges.split()

        if splitResult.isModified {
            edges.eliminateSame()
        }

        state = .sortedByLength
        
        assert(edges.isAsscending())
        
        return splitResult.isGeometryModified
    }
    
    mutating func sortByAngle() {
        guard state != .sortedByAngle else {
            return
        }
        let n = edges.count
        
        var i = 0

        while i < n {
            let i0 = i
            let e = edges[i0]
            
            i += 1
            var m = 1
            while i < n && e.a == edges[i].a {
                i += 1
                m += 1
            }

            if m > 1 {
                var subEdges = [SelfEdge](repeating: .zero, count: m)
                for j in 0..<m {
                    subEdges[j] = edges[i0 + j]
                }

                subEdges.sortByAngle(start: e.a)

                for j in 0..<m {
                    edges[i0 + j] = subEdges[j]
                }
            }
        }

        state = .sortedByAngle
    }
}

private extension Array where Element == FixVec {
    
    var edges: [SelfEdge] {
        let n = count
        var edges = [SelfEdge](repeating: .zero, count: n)
        
        let i0 = n - 1
        var a = self[i0]
        
        for i in 0..<n {
            let b = self[i]
            
            if a.bitPack < b.bitPack {
                edges[i] = SelfEdge(a: a, b: b, n: 1)
            } else {
                edges[i] = SelfEdge(a: b, b: a, n: 1)
            }
            a = b
        }
        
        return edges
    }
}

extension Array where Element == SelfEdge {

    static func merge(a: [SelfEdge], b: [SelfEdge]) -> [SelfEdge] {
        guard !a.isEmpty else { return b }
        guard !b.isEmpty else { return a }
        
        let na = a.count
        let nb = b.count
        
        var result = [SelfEdge]()
        result.reserveCapacity(na + nb)
        
        var ia = 0
        var ib = 0
        
        var ai = a[ia]
        var bi = b[ib]
        while ia < na && ib < nb {
            if ai.a.bitPack < bi.a.bitPack {
                result.append(ai)
                ia += 1
                if ia < na {
                    ai = a[ia]
                }
            } else {
                result.append(bi)
                ib += 1
                if ib < nb {
                    bi = b[ib]
                }
            }
        }
        
        if ia < na {
            result.append(contentsOf: a[ia..<na])
        }
        if ib < nb {
            result.append(contentsOf: b[ib..<nb])
        }
        
        return result
    }
    
    // array must be sorted
    mutating func eliminateSame() {
        // usually (if the path do not have loops) we will not have the same edges, so this code will work very fast
        var i = 0
        while i < count - 1 { // do not need validate last
            let e0 = self[i]
            let i0 = i
            
            // how many same segments
            var s = e0.n
            i += 1
            while i < count && e0 == self[i] {
                s += self[i].n
                i += 1
            }
            
            if s > 1 {
                // if s is even remove all else stay 1

                if s % 2 == 0 {
                    self.removeSubrange(i0..<i)
                    i = i0
                } else {
                    self[i0] = SelfEdge(a: e0.a, b: e0.b, n: 1)
                    
                    let n = i - i0
                    if n > 1 {
                        self.removeSubrange(i0 + 1..<i)
                    }
                    i = i0 + 1
                }
            }
        }
    }
}

private extension Array where Element == SelfEdge {

    mutating func sortByAngle(start: FixVec) {
        self.sort(by: {
            if $0.b.x == $1.b.x {
                return $0.b.y < $1.b.y
            } else {
                return Triangle.isClockwise(p0: start, p1: $1.b, p2: $0.b)
            }
        })
    }
}
