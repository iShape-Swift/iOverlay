//
//  EdgeSubList.swift
//
//
//  Created by Nail Sharipov on 05.05.2024.
//

struct EdgeSubList {
    
    private (set) var edges: [ShapeEdge]
    
    @inlinable
    init(edges: ArraySlice<ShapeEdge>) {
        let n = edges.count
        assert(n > 0)
        self.edges = Array(edges)
    }

    @inlinable
    func first() -> UInt32 {
        if self.edges.isEmpty {
            return .empty
        } else {
            return 0
        }
    }
    
    @inlinable
    func find(xSegment: XSegment) -> UInt32 {
        index(target: xSegment).index
    }
    
    @inlinable
    func findEqualOrNext(xSegment: XSegment) -> UInt32 {
        let result = index(target: xSegment)
        if result.isExist {
            return result.index
        } else if result.index < edges.count {
            return result.index
        } else {
            return .empty
        }
    }
    
    @inlinable
    mutating func getAndRemove(_ index: UInt32) -> ShapeEdge {
        self.edges.remove(at: Int(index))
    }
    
    @inlinable
    mutating func removeAndNext(_ rIndex: UInt32) -> UInt32 {
        self.edges.remove(at: Int(rIndex))
        if rIndex < self.edges.count {
            return rIndex
        } else {
            return .empty
        }
    }
    
    @inlinable
    mutating func remove(edge: ShapeEdge) {
        self.edges.remove(at: Int(self.index(target: edge.xSegment).index))
    }

    @inlinable
    mutating func remove(index: UInt32) {
        self.edges.remove(at: Int(index))
    }
    
    @inlinable
    mutating func update(index: UInt32, count: ShapeCount) {
        self.edges[Int(index)].count = count
    }
    
    @inlinable
    mutating func merge(edge: ShapeEdge) -> UInt32 {
        let result = index(target: edge.xSegment)
        let i = Int(result.index)
        if result.isExist {
            self.edges[i].count = self.edges[i].count.add(edge.count)
        } else {
            self.edges.insert(edge, at: i)
        }

        return result.index
    }
    
    @inlinable
    func index(target: XSegment) -> SearchResult {
        var left = 0
        var right = edges.count
        
        while left < right {
            let mid = left + (right - left) / 2
            if edges[mid].xSegment == target {
                return SearchResult(isExist: true, index: UInt32(mid))
            } else if edges[mid].xSegment.isLess(target) {
                left = mid + 1
            } else {
                right = mid
            }
        }
        
        return SearchResult(isExist: false, index: UInt32(left))
    }
    
}

struct SearchResult {
    let isExist: Bool
    let index: UInt32
}
