//
//  SearchResult.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iShape

struct SearchResult {
    
    let equal: Int
    let left: Int
    let right: Int
    
}

extension Array where Element == SelfEdge {
    
    private static let binaryRange = 8

    func findA(_ edge: FixEdge) -> SearchResult {
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
            } else if e.isLessA(edge) {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }
        
        return SearchResult(equal: -1, left: lt, right: rt)
    }

    func findB(_ edge: FixEdge) -> SearchResult {
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
            } else if e.isLessB(edge) {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }
        
        return SearchResult(equal: -1, left: lt, right: rt)
    }
    
    func findPosA(_ pos: Int64) -> SearchResult {
        guard !self.isEmpty else {
            return SearchResult(equal: 0, left: 0, right: 0)
        }
        
        var lt = 0
        var rt = count - 1
        
        // Perform binary search until the remaining range is below the threshold
        while rt - lt >= Self.binaryRange {
            let i = (rt + lt) / 2
            let e = self[i]
            if e.a.bitPack == pos {
                return SearchResult(equal: i, left: 0, right: 0)
            } else if e.a.bitPack < pos {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }
        
        return SearchResult(equal: -1, left: lt, right: rt)
    }

    
    func findPosB(_ pos: Int64) -> SearchResult {
        guard !self.isEmpty else {
            return SearchResult(equal: 0, left: 0, right: 0)
        }
        
        var lt = 0
        var rt = count - 1
        
        // Perform binary search until the remaining range is below the threshold
        while rt - lt >= Self.binaryRange {
            let i = (rt + lt) / 2
            let e = self[i]
            if e.b.bitPack == pos {
                return SearchResult(equal: i, left: 0, right: 0)
            } else if e.b.bitPack < pos {
                lt = i + 1
            } else {
                rt = i - 1
            }
        }
        
        return SearchResult(equal: -1, left: lt, right: rt)
    }

}
