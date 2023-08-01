//
//  EdgeScanList.swift
//  
//
//  Created by Nail Sharipov on 21.07.2023.
//

import iShape

struct EdgeScanList {
    
    private (set) var edges: [FixEdge]
    private var minEnd: Int64
    
    init() {
        self.edges = [FixEdge]()
        self.edges.reserveCapacity(8)
        self.minEnd = .max
    }
    
    mutating func clear() {
        self.minEnd = .max
        self.edges.removeAll(keepingCapacity: true)
    }
    
    mutating func add(_ edge: FixEdge) {
        edges.append(edge)
        minEnd = min(minEnd, edge.e1.bitPack)
    }
    
    mutating func removeAllEndingBeforePosition(_ pos: Int64) {
        guard minEnd <= pos else { return } // if edges is empty then minEnd === .max
        var minPos = Int64.max
        var i = 0
        var j = edges.count - 1
        var n = 0
        while i <= j {
            let edge = edges[i]
            let bPos = edge.e1.bitPack
            if bPos <= pos {
                edges[i] = edges[j]
                j -= 1
                n += 1
            } else {
                i += 1
                minPos = min(minPos, bPos)
            }
        }
        minEnd = minPos
        edges.removeLast(n)
    }

    mutating func replace(oldIndex: Int, newEdge: SelfEdge) {
        if self.isContain(newEdge.edge) {
            // newEdge is exist, but we still must remove old edge
            edges.remove(at: oldIndex)
        } else {
            // newEdge is not exist, so we only update old edge
            edges[oldIndex] = newEdge.edge
        }
    }

    mutating func removeAllLater(edge: FixEdge) {
        var i = 0
        while i < edges.count {
            let e = edges[i]
            
            if edge.isLess(e) {
                edges.remove(at: i)
            } else {
                i += 1
            }
        }
    }
    
    mutating func addAllOverlapingPosition(_ pos: Int64, start: Int, list: [SelfEdge]) -> Int {
        var i = start
        while i < list.count {
            let edge = list[i]
            guard edge.a.bitPack <= pos else {
                return i
            }
            
            if edge.b.bitPack >= pos {
                edges.append(edge.edge)
            }
            
            i += 1
        }
        
        return i
    }
    
    private func isContain(_ edge: FixEdge) -> Bool {
        for e in edges where e.isEqual(edge) {
            return true
        }
        return false
    }
    
}

private extension FixEdge {
    
    func isLess(_ other: FixEdge) -> Bool {
        let a0 = e0.bitPack
        let a1 = other.e0.bitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            let b0 = e1.bitPack
            let b1 = other.e1.bitPack
            
            return b0 < b1
        }
    }
    
    func isEqual(_ other: FixEdge) -> Bool {
        let a0 = e0.bitPack
        let a1 = other.e0.bitPack
        let b0 = e1.bitPack
        let b1 = other.e1.bitPack
        
        return a0 == a1 && b0 == b1
    }
}
