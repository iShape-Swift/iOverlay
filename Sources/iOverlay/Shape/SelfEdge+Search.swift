//
//  SelfEdge+Search.swift
//  
//
//  Created by Nail Sharipov on 20.07.2023.
//

import iShape

private struct FindEdgeResult {
    
}

// Extension to Array of SelfEdges to support Binary Search operations
// All operations expect the array to be sorted ascending by 'a' of SelfEdge
extension Array where Element == SelfEdge {
    
    private static let binaryRange = 8

    /// Find the index of the edge
    /// - Parameters:
    /// - edge: target edge
    /// - Returns: index of the found edge
    func findEdgeIndex(_ edge: FixEdge) -> Int {
        guard !self.isEmpty else {
            return 0
        }

        var lt = 0
        var rt = count - 1

        // Perform binary search until the remaining range is below the threshold
        while rt - lt >= Self.binaryRange {
            let i = (rt + lt) / 2
            let e = self[i]
            if e.isEqual(edge) {
                return i
            } else if e.isLess(edge) {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }

        // Perform linear search within the remaining range
        var i = lt
        while i <= rt && !self[i].isEqual(edge) {
            i += 1
        }

        return i <= rt ? i : -1
    }
    
    /// Find the index of the edge or first greater
    /// - Parameters:
    /// - edge: target edge
    /// - Returns: index of the found edge
    func findNewEdgeIndex(_ edge: FixEdge) -> Int {
        guard !self.isEmpty else {
            return 0
        }
        
        var lt = 0
        var rt = count - 1
        
        // Perform binary search until the remaining range is below the threshold
        while rt - lt >= Self.binaryRange {
            let i = (rt + lt) / 2
            let e = self[i]
            if e.isEqual(edge) {
                return i
            } else if e.isLess(edge) {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }
        
        // Perform linear search within the remaining range
        var i = lt
        while i <= rt && self[i].isLess(edge) {
            i += 1
        }
        
        return i
    }
    
    func findAnyIndexByStart(_ value: Int64) -> Int {
        guard !self.isEmpty else {
            return 0
        }
        
        var lt = 0
        var rt = count - 1
        
        // Perform binary search until the remaining range is below the threshold
        while rt - lt >= Self.binaryRange {
            let i = (rt + lt) / 2
            let a = self[i].a.bitPack
            if a == value {
                return i
            } else if a < value {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }
        
        // Perform linear search within the remaining range
        var i = lt
        while i <= rt && self[i].a.bitPack < value {
            i += 1
        }
        
        return i
    }

    mutating func addAndMerge(_ newEdge: SelfEdge) -> Int {
        let index = self.findNewEdgeIndex(newEdge.edge)
        
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

    func isAsscending() -> Bool {
        var i = 1
        var e0 = self[0]
        while i < count {
            let ei = self[i]
            if !e0.isLess(ei) {
                return false
            }

            e0 = ei
            i += 1
        }
        
        return true
    }
}
