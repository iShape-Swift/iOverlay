//
//  EdgeStore.swift
//
//
//  Created by Nail Sharipov on 26.04.2024.
//

struct StoreIndex {
    let tree: UInt32
    let node: UInt32
}

struct EdgeStore {
    
    private var ranges: [Int32]
    private var trees: [EdgeSubTree]
    private static let rangeLength: Int = 8
    
    
    init(edges: [ShapeEdge]) {
        // array must be sorted
        guard edges.count > Self.rangeLength else {
            self.ranges = []
            self.trees = [EdgeSubTree(edges: edges[...])]
            return
        }
        
        let n = edges.count / Self.rangeLength
        
        var ranges = [Int32]()
        ranges.reserveCapacity(n - 1)
        
        var trees = [EdgeSubTree]()
        trees.reserveCapacity(n)

        var i = 0
        while i < edges.count {
            var j = i
            var x = edges[i].xSegment.a.x
            while j < edges.count {
                let xj = edges[j].xSegment.a.x
                if x != xj {
                    if j - i >= Self.rangeLength {
                        break
                    }
                    x = xj
                }
                j += 1
            }
            trees.append(EdgeSubTree(edges: edges[i..<j]))
            i = j
            
            if i < edges.count {
                ranges.append(x)
            }
        }
        
        self.ranges = ranges
        self.trees = trees
    }
    
    func first(index: UInt32) -> StoreIndex {
        let i0 = Int(index)
        let i1 = trees.count
        for i in i0..<i1 {
            let firstIndex = trees[i].tree.firstByOrder()
            if firstIndex != .empty {
                return StoreIndex(tree: UInt32(i), node: firstIndex)
            }
        }
        
        return StoreIndex(tree: .empty, node: .empty)
    }
    
    func edge(_ index: StoreIndex) -> ShapeEdge {
        self.trees[Int(index.tree)].tree[index.node].value
    }
    
    func find(xSegment: XSegment) -> StoreIndex {
        let tree = self.findTree(x: xSegment.a.x)
        let node = self.trees[tree].find(xSegment: xSegment)
        return StoreIndex(tree: UInt32(tree), node: node)
    }
    
    func findEqualOrNext(tree: UInt32, xSegment: XSegment) -> StoreIndex {
        let node = self.trees[Int(tree)].findEqualOrNext(xSegment: xSegment)
        if node == .empty {
            return self.first(index: tree + 1)
        } else {
            return StoreIndex(tree: tree, node: node)
        }
    }
    
    mutating func removeAndNext(_ index: StoreIndex) -> StoreIndex {
        let next = self.trees[Int(index.tree)].removeAndNext(index.node)
        guard next == .empty else {
            return StoreIndex(tree: index.tree, node: next)
        }
        
        return self.first(index: index.tree + 1)
    }
    
    mutating func next(_ index: StoreIndex) -> StoreIndex {
        let next = self.trees[Int(index.tree)].tree.nextByOrder(index: index.node)
        guard next == .empty else {
            return StoreIndex(tree: index.tree, node: next)
        }
        
        return self.first(index: index.tree + 1)
    }
    
    func get(_ index: StoreIndex) -> ShapeEdge {
        self.trees[Int(index.tree)].tree[index.node].value
    }
    
    mutating func getAndRemove(_ index: StoreIndex) -> ShapeEdge {
        self.trees[Int(index.tree)].getAndRemove(index.node)
    }
    
    mutating func remove(edge: ShapeEdge) {
        let tree = self.findTree(x: edge.xSegment.a.x)
        self.trees[Int(tree)].remove(edge: edge)
    }
    
    mutating func remove(index: StoreIndex) {
        self.trees[Int(index.tree)].remove(index: index.node)
    }
    
    mutating func update(_ index: StoreIndex, count: ShapeCount) {
        self.trees[Int(index.tree)].update(index: index.node, count: count)
    }
    
    mutating func addAndMerge(newEdge: ShapeEdge) -> StoreIndex {
        let tree = self.findTree(x: newEdge.xSegment.a.x)
        let node = self.trees[tree].merge(edge: newEdge)
        return StoreIndex(tree: UInt32(tree), node: node)
    }
    
    private func findTree(x: Int32) -> Int {
        guard !ranges.isEmpty else {
            return 0
        }
        return ranges.findIndex(target: x)
    }
    
    func segments() -> [Segment] {
        var result = [Segment]()
        if trees.count > 1 {
            result.reserveCapacity(trees.count * Self.rangeLength)
        }

        var sIndex = self.first(index: 0)

        while sIndex.node != .empty {
            let tree = trees[Int(sIndex.tree)].tree
            var nIndex = tree.firstByOrder()
            while nIndex != .empty {
                let e = tree[nIndex].value
                result.append(Segment(edge: e))
                nIndex = tree.nextByOrder(index: nIndex)
            }

            sIndex = self.first(index: sIndex.tree + 1)
        }

        return result
    }
    
}

private extension Array where Element == Int32 {
    
    func findIndex(target: Int32) -> Int {
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


struct TestFindIndex {
    static func findIndex(array: [Int32], target: Int32) -> Int {
        array.findIndex(target: target)
    }
}
