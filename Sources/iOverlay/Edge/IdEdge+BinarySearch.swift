//
//  IdEdge+BinarySearch.swift
//  
//
//  Created by Nail Sharipov on 07.07.2023.
//

// array must be descending
extension Array where Element == IdEdge {

    // sorted by e0
    
    /// Find edge with e0 equal or first less
    /// - Parameters:
    ///   - value: place
    /// - Returns: edge index
    func findIndexE0(_ value: Int64) -> Int {
        guard !self.isEmpty else {
            return 0
        }
        
        var lt = 0
        var rt = count - 1
        
        while rt - lt > 0 {
            let i = (rt + lt) / 2
            let a = self[i].e0.bitPack
            if a == value {
                return i
            } else if a > value {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }

        let last = self[lt].e0.bitPack
        if last > value {
            return lt + 1
        } else {
            return lt
        }
    }
    
    mutating func addE0(edge: IdEdge) {
        let index = self.findIndexE0(edge.e0.bitPack)
        self.insert(edge, at: index)
    }
    
    // sorted by e1
    
    /// Find edge with e1 equal or first less
    /// - Parameters:
    ///   - value: place
    /// - Returns: edge index
    func findIndexE1(_ value: Int64) -> Int {
        guard !self.isEmpty else {
            return 0
        }
        
        var lt = 0
        var rt = count - 1
        
        while rt - lt > 0 {
            let i = (rt + lt) / 2
            let a = self[i].e1.bitPack
            if a == value {
                return i
            } else if a > value {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }

        let last = self[lt].e1.bitPack
        if last > value {
            return lt + 1
        } else {
            return lt
        }
    }

    mutating func removeAllE1(before: Int64) {
        let n = allE1(before: before)
        if n > 0 {
            self.removeLast(n)
        }
    }
    
    func allE1(before: Int64) -> Int {
        guard !self.isEmpty else { return 0 }
        var i = count - 1
        
        while i >= 0 && self[i].e1.bitPack < before {
            i -= 1
        }

        return count - i - 1
    }

    
    mutating func addE1(edge: IdEdge) {
        let i = self.findIndexE1(edge.e1.bitPack)
        self.insert(edge, at: i)
    }
}
