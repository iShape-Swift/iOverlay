//
//  EdgeRangeList.swift
//
//
//  Created by Nail Sharipov on 22.11.2023.
//

struct EdgeRangeList {
    
    private var ranges: [Int64]
    private var lists: [EdgeLinkedList]
    private static let rangeLength: Int = 2
    
    func edge(index: DualIndex) -> ShapeEdge {
        self.lists.withUnsafeBufferPointer { listsBuffer -> ShapeEdge in
            let mainList = listsBuffer.baseAddress!.advanced(by: Int(index.base)).pointee
            return mainList.nodes.withUnsafeBufferPointer { nodesBuffer -> ShapeEdge in
                nodesBuffer.baseAddress!.advanced(by: Int(index.node)).pointee.edge
            }
        }
    }
    
    func validateEdge(vIndex: VersionedIndex) -> ShapeEdge? {
        let node = self.lists[Int(vIndex.index.base)].nodes[Int(vIndex.index.node)]
        if node.isRemoved {
            return nil
        } else {
            return node.edge
        }
    }

    func first() -> VersionedIndex {
        self.first(index: 0)
    }
    
    private func first(index: UInt32) -> VersionedIndex {
        var i = Int(index)
        while i < lists.count {
            let firstIndex = lists[i].firstIndex
            if firstIndex != .max {
                let node = lists[i].nodes[Int(firstIndex)]
                return VersionedIndex(version: node.version, index: .init(base: UInt32(i), node: firstIndex))
            }
            i += 1
        }
        
        return .empty
    }

    func next(index: DualIndex) -> VersionedIndex {
        let node = lists[Int(index.base)].nodes[Int(index.node)]
        if node.next != .max {
            return VersionedIndex(version: node.version, index: .init(base: index.base, node: node.next))
        } else if index.base < lists.count {
            return self.first(index: index.base + 1)
        } else {
            return .empty
        }
    }

    mutating func removeAndNext(index: DualIndex) -> VersionedIndex {
        let nextIndex = self.next(index: index)
        self.lists[Int(index.base)].remove(index: index.node)
        return nextIndex
    }
    
    mutating func remove(index: DualIndex) {
        self.lists[Int(index.base)].remove(index: index.node)
    }
    
    mutating func update(index: DualIndex, edge: ShapeEdge) -> UInt32  {
        self.lists[Int(index.base)].update(index: index.node, edge: edge)
    }
  
    mutating func update(index: DualIndex, count: ShapeCount) -> UInt32 {
        self.lists[Int(index.base)].update(index: index.node, count: count)
    }
    
    mutating func addAndMerge(anchorIndex: DualIndex, newEdge: ShapeEdge) -> VersionedIndex {
        let index = self.findIndex(anchorIndex: anchorIndex, edge: newEdge)
        let edge = self.edge(index: index)
        let version: UInt32
        if edge.isEqual(newEdge) {
            version = self.update(index: index, count: edge.count.add(newEdge.count))
        } else {
            version = self.update(index: index, edge: newEdge)
        }

        return VersionedIndex(version: version, index: index)
    }
    
    mutating func findIndex(anchorIndex: DualIndex, edge: ShapeEdge) -> DualIndex {
        let a = edge.aBitPack
        let base: UInt32
        let node: UInt32
        if ranges[Int(anchorIndex.base)] < a && a <= ranges[Int(anchorIndex.base + 1)] {
            base = anchorIndex.base
            node = lists[Int(base)].find(anchorIndex: anchorIndex.node, edge: edge)
        } else {
            base = UInt32(ranges.findIndex(target: a)) - 1 // -1 is ranges offset
            node = lists[Int(base)].findFromStart(edge: edge)
        }

        return DualIndex(base: base, node: node)
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
        var n = 0
        for list in lists {
            n += list.nodes.count
        }
        var result = [ShapeEdge]()
        result.reserveCapacity(n)
        
        var vIndex = self.first()

        while vIndex.isNotNil {
            result.append(edge(index: vIndex.index))
            vIndex = self.next(index: vIndex.index)
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
