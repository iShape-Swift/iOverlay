//
//  SplitRangeList.rift
//
//
//  Created by Nail Sharipov on 22.11.2023.
//

struct SplitRangeList {
    
    private var ranges: [UInt64]
    private var lists: [SplitLinkedList]
    private static let rangeLength: Int = 2
    
    func edge(index: DualIndex) -> ShapeEdge {
        self.lists.withUnsafeBufferPointer { listsBuffer -> ShapeEdge in
            let mainList = listsBuffer.baseAddress!.advanced(by: Int(index.major)).pointee
            return mainList.nodes.withUnsafeBufferPointer { nodesBuffer -> ShapeEdge in
                nodesBuffer.baseAddress!.advanced(by: Int(index.minor)).pointee.edge
            }
        }
    }
    
    func validateEdge(vIndex: VersionedIndex) -> ShapeEdge? {
        let node = self.lists[Int(vIndex.index.major)].nodes[Int(vIndex.index.minor)]
        if node.version != vIndex.version {
            return nil
        } else {
            return node.edge
        }
    }

    func first() -> VersionedIndex {
        self.first(index: 0)
    }
    
    private func first(index: UInt32) -> VersionedIndex {
        let i0 = Int(index)
        let i1 = lists.count
        for i in i0..<i1 {
            let firstIndex = lists[i].firstIndex
            if firstIndex != .max {
                let node = lists[i].nodes[Int(firstIndex)]
                return VersionedIndex(version: node.version, index: .init(major: UInt32(i), minor: firstIndex))
            }
        }
        
        return .empty
    }

    func next(index: DualIndex) -> VersionedIndex {
        let node = lists[Int(index.major)].nodes[Int(index.minor)]
        if node.next != .max {
            let version = lists[Int(index.major)].nodes[Int(node.next)].version
            return VersionedIndex(version: version, index: .init(major: index.major, minor: node.next))
        } else if index.major < lists.count {
            return self.first(index: index.major + 1)
        } else {
            return .empty
        }
    }

    mutating func removeAndNext(index: DualIndex) -> VersionedIndex {
        let nextIndex = self.next(index: index)
        self.lists[Int(index.major)].remove(index: index.minor)
        return nextIndex
    }
    
    mutating func remove(index: DualIndex) {
        self.lists[Int(index.major)].remove(index: index.minor)
    }
    
    mutating func update(index: DualIndex, edge: ShapeEdge) -> UInt32  {
        self.lists[Int(index.major)].update(index: index.minor, edge: edge)
    }
  
    mutating func update(index: DualIndex, count: ShapeCount) -> UInt32 {
        self.lists[Int(index.major)].update(index: index.minor, count: count)
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
        let a = edge.a.bitPack
        let base: UInt32
        let node: UInt32
        if ranges[Int(anchorIndex.major)] < a && a <= ranges[Int(anchorIndex.major + 1)] {
            base = anchorIndex.major
            node = lists[Int(base)].find(anchorIndex: anchorIndex.minor, edge: edge)
        } else {
            base = UInt32(ranges.findIndex(target: a)) - 1 // -1 is ranges offset
            node = lists[Int(base)].findFromStart(edge: edge)
        }

        return DualIndex(major: base, minor: node)
    }
    
    init(edges: [ShapeEdge]) {
        // array must be sorted

        let n = (edges.count - 1) / Self.rangeLength + 1
        let length = edges.count / n
        
        var ranges = [UInt64]()
        ranges.reserveCapacity(n + 1)
        ranges.append(UInt64.min)
        
        var lists = [SplitLinkedList]()
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
                lists.append(SplitLinkedList(edges: slice))
                ranges.append(UInt64.max)
                break
            } else {
                let slice = edges[i0..<i]
                lists.append(SplitLinkedList(edges: slice))
                ranges.append(a.bitPack)
            }
        }

        self.ranges = ranges
        self.lists = lists
    }
    
    func segments() -> [Segment] {
        var n = 0
        for list in lists {
            n += list.nodes.count
        }
        var result = [Segment]()
        result.reserveCapacity(n)
        
        var vIndex = self.first()

        while vIndex.isNotNil {
            let e = edge(index: vIndex.index)
            result.append(Segment(edge: e))
            vIndex = self.next(index: vIndex.index)
        }

        return result
    }
    
}

private extension Array where Element == UInt64 {
    
    func findIndex(target: UInt64) -> Int {
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
