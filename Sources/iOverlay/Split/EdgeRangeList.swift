//
//  EdgeRangeList.swift
//
//
//  Created by Nail Sharipov on 22.11.2023.
//

struct EdgeRangeList {
    
    private var ranges: [Int64]
    private var lists: [EdgeLinkedList]
    private static let rangeLength: Int = 128
    
    func edge(index: CompositeIndex) -> ShapeEdge {
        self.lists[Int(index.main)].nodes[Int(index.list)].edge
    }

    func first() -> CompositeIndex {
        self.first(index: 0)
    }
    
    private func first(index: UInt32) -> CompositeIndex {
        var i = Int(index)
        while i < lists.count {
            let firstIndex = lists[i].firstIndex
            if firstIndex != .max {
                return CompositeIndex(main: UInt32(i), list: firstIndex)
            }
            i += 1
        }
        
        return CompositeIndex(main: .max, list: .max)

    }

    func next(index: CompositeIndex) -> CompositeIndex {
        let node = lists[Int(index.main)].nodes[Int(index.list)]
        if node.next != .max {
            return CompositeIndex(main: index.main, list: node.next)
        } else if index.main < lists.count {
            return self.first(index: index.main + 1)
        } else {
            return .empty
        }
    }

    mutating func removeAndNext(index: CompositeIndex) -> CompositeIndex {
        let nextIndex = self.next(index: index)
        self.lists[Int(index.main)].remove(index: index.list)
        return nextIndex
    }
    
    mutating func remove(index: CompositeIndex) {
        self.lists[Int(index.main)].remove(index: index.list)
    }
    
    mutating func update(index: CompositeIndex, edge: ShapeEdge) {
        self.lists[Int(index.main)].update(index: index.list, edge: edge)
    }
    
    mutating func addAndMerge(anchorIndex: CompositeIndex, newEdge: ShapeEdge) -> CompositeIndex {
        let index = self.findIndex(anchorIndex: anchorIndex, edge: newEdge)
        let edge = self.edge(index: index)
        if edge.isEqual(newEdge) {
            let count = edge.count.add(newEdge.count)
            self.update(index: index, edge: ShapeEdge(parent: newEdge, count: count))
        } else {
            self.update(index: index, edge: newEdge)
        }
        
        return index
    }
    
    mutating func findIndex(anchorIndex: CompositeIndex, edge: ShapeEdge) -> CompositeIndex {
        let a = edge.aBitPack
        let mainIndex: UInt32
        let listIndex: UInt32
        if ranges[Int(anchorIndex.main)] < a && a <= ranges[Int(anchorIndex.main + 1)] {
            mainIndex = anchorIndex.main
            listIndex = lists[Int(mainIndex)].find(anchorIndex: anchorIndex.list, edge: edge)
        } else {
            mainIndex = UInt32(ranges.findIndex(target: a)) - 1 // -1 is ranges offset
            listIndex = lists[Int(mainIndex)].findFromStart(edge: edge)
        }

        return CompositeIndex(main: mainIndex, list: listIndex)
    }
    
    init(edges: [ShapeEdge]) {
        // array must be sorted

        let n = (edges.count - 1) / Self.rangeLength + 1
        let length = edges.count / n
        
        var ranges = [Int64]()
        ranges.reserveCapacity(n + 1)
        ranges.append(Int64.min)
        
        var lists = [EdgeLinkedList]()
        lists.reserveCapacity(n)
        
        let minLength = Self.rangeLength / 2 + 1
        
        var i = 0
        while i < edges.count {
            let i0 = i
            
            i = min(edges.count - 1, i + length)
            
            let a = edges[i].a
            i += 1
            while i < edges.count && edges[i].a == a {
                i += 1
            }
            
            if i + minLength >= edges.count {
                let slice = edges[i0..<edges.count]
                lists.append(EdgeLinkedList(edges: slice))
                ranges.append(Int64.max)
                break
            } else {
                let slice = edges[i0..<i]
                lists.append(EdgeLinkedList(edges: slice))
                ranges.append(a.bitPack)
            }
        }

        self.ranges = ranges
        self.lists = lists
    }
    
    func edges() -> [ShapeEdge] {
        var result = [ShapeEdge]()
        var index = self.first()

        while index.isValid {
            result.append(edge(index: index))
            index = self.next(index: index)
        }
        
        return result
    }
    
}

private extension Array where Element == Int64 {
    
    func findIndex(target: Int64) -> Int {
        var left = 0
        var right = self.count

        while left < right {
            let mid = left + (right - left) / 2
            if self[mid] == target {
                return mid
            } else if self[mid] < target {
                left = mid + 1
            } else {
                right = mid
            }
        }
        
        return left
    }
}
