//
//  BoolShape.swift
//  
//
//  Created by Nail Sharipov on 20.07.2023.
//

import iFixFloat
import iShape

public struct BoolShape {
    
    public internal (set) var edges: [SelfEdge]
    private var isDirty: Bool
    private var isSorted: Bool
    
    public init(capacity: Int) {
        edges = [SelfEdge]()
        edges.reserveCapacity(capacity)
        isDirty = false
        isSorted = true
    }

    public mutating func add(path: [FixVec]) {
        guard path.count > 2 else { return }
        let clean = path.removedDegenerates()
        guard clean.count > 2 else { return }
        
        isDirty = true
        isSorted = false
        edges.append(contentsOf: clean.edges)
    }
    
    public mutating func unsafeAdd(path: [FixVec]) {
        isSorted = false
        edges.append(contentsOf: path.edges)
    }

    public mutating func fix() -> Bool {
        if !isSorted {
            edges.sort(by: { $0.isLess($1) })
            isSorted = true
        }
        
        if isDirty {
            edges.eliminateSame()
            
            assert(edges.isAsscending())
        
            let splitResult = edges.split()

            if splitResult.isModified {
                edges.eliminateSame()
            }

            isDirty = false
            
            assert(edges.isAsscending())
            
            return splitResult.isGeometryModified
        } else {
            return false
        }
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
