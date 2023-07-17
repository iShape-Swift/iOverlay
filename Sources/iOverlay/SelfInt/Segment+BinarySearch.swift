//
//  Segment+BinarySearch.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iShape

// array must be ascending by a
extension Array where Element == Segment {
    
    private static let binaryRange = 8
    
    /// Find segment with a equal or first greater
    /// - Parameters:
    ///   - value: place
    /// - Returns: segment index
    func findIndexByA(_ value: Int64) -> Int {
        guard !self.isEmpty else {
            return 0
        }
        
        var lt = 0
        var rt = count - 1
        
        while rt - lt >= Self.binaryRange {
            let i = (rt + lt) / 2
            let a = self[i].a.point.bitPack
            if a == value {
                return i
            } else if a < value {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }
        
        var i = lt
        while i <= rt && self[i].a.point.bitPack < value {
            i += 1
        }
        
        return i
    }
    
    mutating func insertSegmentSortedByA(_ seg: Segment) {
        let index = self.findIndexByA(seg.a.point.bitPack)
        self.insert(seg, at: index)
    }
    
    /// Find segment by Id
    /// - Parameters:
    ///   - id: segment id
    ///   - value: segment a value
    /// - Returns: segment index
    func findById(_ id: Int, value: Int64) -> Int {
        assert(!self.isEmpty)
        
        let i0 = self.findIndexByA(value)
        
        guard self[i0].id != id else {
            return i0
        }
        
        var i = i0 - 1
        while i >= 0 {
            let e = self[i]
            if e.a.point.bitPack != value {
                break
            }
            
            if e.id == id {
                return i
            }

            i -= 1
        }

        i = i0 + 1
        while i < count {
            let e = self[i]
            if e.a.point.bitPack != value {
                break
            }
            
            if e.id == id {
                return i
            }

            i += 1
        }

        return -1
    }
    
}
