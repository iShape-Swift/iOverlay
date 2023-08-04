//
//  SelfEdge+bSort.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape

// Extension to Array of SelfEdges to support Binary Search operations
// All operations expect the array to be sorted ascending by 'a' of SelfEdge
extension Array where Element == SelfEdge {

    func bFindMore(_ point: FixVec) -> Int {
        let pos = point.bitPack
        let result = findPosB(pos)
        guard result.equal == -1 else {
            return result.equal
        }
        
        // Perform linear search within the remaining range
        var i = result.left
        while i <= result.right && self[i].b.bitPack < pos {
            i += 1
        }
        
        return i
    }
    
    func bFindNewEdgeIndex(_ edge: FixEdge) -> Int {
        let result = findB(edge)
        guard result.equal == -1 else {
            return result.equal
        }
        
        // Perform linear search within the remaining range
        var i = result.left
        while i <= result.right && self[i].isLessB(edge) {
            i += 1
        }
        
        return i
    }

    mutating func bAddAndMerge(_ newEdge: SelfEdge) -> Int {
        let index = self.bFindNewEdgeIndex(newEdge.edge)
        
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

    func isAsscendingB() -> Bool {
        guard count > 1 else {
            return true
        }
        var i = 1
        var e0 = self[0]
        while i < count {
            let ei = self[i]
            if !e0.isLessB(ei) {
                return false
            }

            e0 = ei
            i += 1
        }
        
        return true
    }
}
