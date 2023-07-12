//
//  Segment+BinarySearch.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iShape

// array must be descending
extension Array where Element == Segment {

    // sorted by a
    
    /// Find edge with a equal or first less
    /// - Parameters:
    ///   - value: place
    /// - Returns: edge index
    func findIndexA(_ value: Int64) -> Int {
        guard !self.isEmpty else {
            return 0
        }
        
        var lt = 0
        var rt = count - 1
        
        while rt - lt > 0 {
            let i = (rt + lt) / 2
            let a = self[i].a.bitPack
            if a == value {
                return i
            } else if a > value {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }

        let last = self[lt].a.bitPack
        if last > value {
            return lt + 1
        } else {
            return lt
        }
    }
    
    mutating func addA(_ seg: Segment) {
        let index = self.findIndexA(seg.a.bitPack)
        self.insert(seg, at: index)
    }
    
    // sorted by b
    
    /// Find edge with b equal or first less
    /// - Parameters:
    ///   - value: place
    /// - Returns: edge index
    func findIndexB(_ value: Int64) -> Int {
        guard !self.isEmpty else {
            return 0
        }
        
        var lt = 0
        var rt = count - 1
        
        while rt - lt > 0 {
            let i = (rt + lt) / 2
            let a = self[i].b.bitPack
            if a == value {
                return i
            } else if a > value {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }

        let last = self[lt].b.bitPack
        if last > value {
            return lt + 1
        } else {
            return lt
        }
    }

    mutating func removeAllB(before: Int64) {
        let n = allB(before: before)
        if n > 0 {
            self.removeLast(n)
        }
    }
    
    func allB(before: Int64) -> Int {
        guard !self.isEmpty else { return 0 }
        var i = count - 1
        
        while i >= 0 && self[i].b.bitPack < before {
            i -= 1
        }

        return count - i - 1
    }

    
    mutating func addB(_ seg: Segment) {
        let i = self.findIndexB(seg.b.bitPack)
        self.insert(seg, at: i)
    }
}
