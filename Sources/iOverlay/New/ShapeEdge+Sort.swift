//
//  ShapeEdge+Sort.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape

private struct SearchResult {
    let equal: Int
    let left: Int
    let right: Int
}

// All operations expect the array to be sorted ascending by 'a' of SelfEdge
extension Array where Element == ShapeEdge {
    
    private static let binaryRange = 8

    private func find(_ edge: FixEdge) -> SearchResult {
        guard !self.isEmpty else {
            return SearchResult(equal: 0, left: 0, right: 0)
        }
        
        var lt = 0
        var rt = count - 1
        
        // Perform binary search until the remaining range is below the threshold
        while rt - lt >= Self.binaryRange {
            let i = (rt + lt) / 2
            let e = self[i]
            if e.isEqual(edge) {
                return SearchResult(equal: i, left: 0, right: 0)
            } else if e.isLess(edge) {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }
        
        return SearchResult(equal: -1, left: lt, right: rt)
    }

    func findEdgeIndex(_ edge: FixEdge) -> Int {
        let result = find(edge)
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

    func findNewEdgeIndex(_ edge: FixEdge) -> Int {
        let result = find(edge)
        guard result.equal == -1 else {
            return result.equal
        }
        
        // Perform linear search within the remaining range
        var i = result.left
        while i <= result.right && self[i].isLess(edge) {
            i += 1
        }
        
        return i
    }

    mutating func addAndMerge(_ newEdge: ShapeEdge) -> Int {
        let index = self.findNewEdgeIndex(newEdge.edge)
        
        let count = mergeCount(index: index, newEdge: newEdge)
        
        if count.isEmpty {
            self.insert(newEdge, at: index)
        } else {
            self[index] = ShapeEdge(parent: newEdge, count: count)
        }
        
        return index
    }
    
    private func mergeCount(index: Int, newEdge: ShapeEdge) -> ShapeCount {
        if index < count {
            let existed = self[index]
            if existed.isEqual(newEdge.edge) {
                return existed.count.add(newEdge.count)
            }
        }
        
        return ShapeCount(subj: -1, clip: -1)
    }

    func isAsscending() -> Bool {
        guard count > 1 else {
            return true
        }
        
        var i = 1
        var e0 = self[0]
        while i < count {
            let ei = self[i]
            assert(e0.a != e0.b)
            if !e0.isLess(ei) {
                return false
            }
            e0 = ei
            i += 1
        }
        
        return true
    }
}

extension ShapeEdge {

    @inlinable
    func isLess(_ other: FixEdge) -> Bool {
        let a0 = a.bitPack
        let a1 = other.e0.bitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            let b0 = b.bitPack
            let b1 = other.e1.bitPack
            
            return b0 < b1
        }
    }
    
    @inlinable
    func isEqual(_ other: FixEdge) -> Bool {
        let a0 = a.bitPack
        let a1 = other.e0.bitPack
        let b0 = b.bitPack
        let b1 = other.e1.bitPack
        
        return a0 == a1 && b0 == b1
    }

    @inlinable
    func isLess(_ other: ShapeEdge) -> Bool {
        let a0 = a.bitPack
        let a1 = other.a.bitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            let b0 = b.bitPack
            let b1 = other.b.bitPack
            
            return b0 < b1
        }
    }
    
    @inlinable
    func isLessOrEqual(_ other: ShapeEdge) -> Bool {
        let a0 = a.bitPack
        let a1 = other.a.bitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            let b0 = b.bitPack
            let b1 = other.b.bitPack
            
            return b0 <= b1
        }
    }
    
    @inlinable
    func isEqual(_ other: ShapeEdge) -> Bool {
        let a0 = a.bitPack
        let a1 = other.a.bitPack
        let b0 = b.bitPack
        let b1 = other.b.bitPack
        
        return a0 == a1 && b0 == b1
    }

}
