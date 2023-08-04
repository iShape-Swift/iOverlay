//
//  SelfEdge+aSort.swift
//  
//
//  Created by Nail Sharipov on 20.07.2023.
//

import iShape

// Extension to Array of SelfEdges to support Binary Search operations
// All operations expect the array to be sorted ascending by 'a' of SelfEdge
extension Array where Element == SelfEdge {
    
    private static let binaryRange = 8

    func aFindAny(_ pos: Int64) -> Int {
        let result = findPosA(pos)
        guard result.equal == -1 else {
            return result.equal
        }
        
        // Perform linear search within the remaining range
        var i = result.left
        while i <= result.right && self[i].a.bitPack < pos {
            i += 1
        }
        
        return i
    }
    
    func aFindEdgeIndex(_ edge: FixEdge) -> Int {
        let result = findA(edge)
        guard result.equal == -1 else {
            return result.equal
        }

        // Perform linear search within the remaining range
        var i = result.left
        while i <= result.right && !self[i].isEqual(edge) {
            i += 1
        }

        return i <= result.right ? i : -1
    }

    func aFindNewEdgeIndex(_ edge: FixEdge) -> Int {
        let result = findA(edge)
        guard result.equal == -1 else {
            return result.equal
        }
        
        // Perform linear search within the remaining range
        var i = result.left
        while i <= result.right && self[i].isLessA(edge) {
            i += 1
        }
        
        return i
    }

    mutating func aAddAndMerge(_ newEdge: SelfEdge) -> Int {
        let index = self.aFindNewEdgeIndex(newEdge.edge)
        
        let n = mergeCount(index: index, newEdge: newEdge)
        
        if n > 0 {
            self[index] = SelfEdge(parent: newEdge, n: n)
        } else {
            self.insert(newEdge, at: index)
        }
        
        return index
    }
    
    private func mergeCount(index: Int, newEdge: SelfEdge) -> Int {
        if index < count {
            let existed = self[index]
            if existed == newEdge {
                return existed.n + newEdge.n
            }
        }
        return 0
    }

    func isAsscendingA() -> Bool {
        guard count > 1 else {
            return true
        }
        var i = 1
        var e0 = self[0]
        while i < count {
            let ei = self[i]
            if !e0.isLessA(ei) {
                return false
            }

            e0 = ei
            i += 1
        }
        
        return true
    }
}
