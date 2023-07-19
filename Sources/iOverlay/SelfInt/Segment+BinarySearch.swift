//
//  Segment+BinarySearch.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iShape

// Extension to Array of Segments to support Binary Search operations
// All operations expect the array to be sorted ascending by 'a' of Segment
extension Array where Element == Segment {
    
    private static let binaryRange = 8
    
    /// Find the index of the segment with 'a' equal or first greater
    /// - Parameters:
    ///   - value: target bit-packed point value
    /// - Returns: index of the found segment
    func findIndexByA(_ value: Int64) -> Int {
        guard !self.isEmpty else {
            return 0
        }
        
        var lt = 0
        var rt = count - 1
        
        // Perform binary search until the remaining range is below the threshold
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
        
        // Perform linear search within the remaining range
        var i = lt
        while i <= rt && self[i].a.point.bitPack < value {
            i += 1
        }
        
        return i
    }

    /// Insert a new segment into the array if it does not already exist
    /// - Parameters:
    ///   - segment: Segment to insert
    mutating func insertIfNotExist(_ segment: Segment) {
        let start = self.findIndexByA(segment.a.point.bitPack)
        if !self.isContain(segment, searchAnchor: start) {
            self.insert(segment, at: start)
        }
    }

    // Replace an existing segment at a given index with a new segment
    // If the new segment already exists, remove the old segment and return the existing index
    // If the new segment does not exist, update the segment at the old index and return the old index
    mutating func replace(oldIndex: Int, newSegment: Segment) -> Int {
        let existedIndex = self.segmentIndex(newSegment, searchAnchor: oldIndex)
        if existedIndex != -1 {
            // New segment already exists; we still must remove old segment
            self.remove(at: oldIndex)
            return existedIndex
        } else {
            // New segment does not exist; replace old segment with new segment
            self[oldIndex] = newSegment
            return oldIndex
        }
    }
    
    // Replace an existing segment with a new segment, returning the index of the replaced or existing segment
    mutating func replace(oldSegment: Segment, newSegment: Segment) -> Int {
        let oldIndex = self.segmentIndex(oldSegment)
        return self.replace(oldIndex: oldIndex, newSegment: newSegment)
    }
    
    // Find the index of a given segment, asserts that segment must exist in array
    func segmentIndex(_ seg: Segment) -> Int {
        let searchAnchor = self.findIndexByA(seg.a.point.bitPack)
        let index = self.segmentIndex(seg, searchAnchor: searchAnchor)
        assert(index != -1)
        return index
    }
    
    // Search for the index of a given segment starting from a specified search anchor, both forwards and backwards
    private func segmentIndex(_ seg: Segment, searchAnchor: Int) -> Int {

        // Forward search
        var i = searchAnchor
        while i < count {
            let s = self[i]
            if s.a.index == seg.a.index {
                if s.b.index == seg.b.index {
                    return i
                }
                i += 1
            } else {
                break
            }
        }
        
        // Reverse search
        i = searchAnchor - 1
        while i >= 0 {
            let s = self[i]
            if s.a.index == seg.a.index {
                if s.b.index == seg.b.index {
                    return i
                }
                i -= 1
            } else {
                break
            }
        }

        return -1
    }
    
    private func isContain(_ seg: Segment, searchAnchor: Int) -> Bool {
        self.segmentIndex(seg, searchAnchor: searchAnchor) != -1
    }

}
