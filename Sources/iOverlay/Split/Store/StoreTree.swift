//
//  StoreTree.swift
//
//
//  Created by Nail Sharipov on 10.05.2024.
//

struct StoreTree {
    
    private var ranges: [Int32]
    private var subStores: [SubStoreTree]
    private let chunkStartLength: Int

    init(ranges: [Int32], subStores: [SubStoreTree], chunkStartLength: Int) {
        self.ranges = ranges
        self.subStores = subStores
        self.chunkStartLength = chunkStartLength
    }
    
    init(edges: [ShapeEdge], chunkStartLength: Int) {
        // array must be sorted
        self.chunkStartLength = chunkStartLength
        guard edges.count > chunkStartLength else {
            self.ranges = []
            self.subStores = [SubStoreTree(edges: edges[...])]
            return
        }
        
        let n = edges.count / chunkStartLength
        
        var ranges = [Int32]()
        ranges.reserveCapacity(n - 1)
        
        var stores = [SubStoreTree]()
        stores.reserveCapacity(n)

        var i = 0
        while i < edges.count {
            var j = i
            var x = edges[i].xSegment.a.x
            while j < edges.count {
                let xj = edges[j].xSegment.a.x
                if x != xj {
                    if j - i >= chunkStartLength {
                        break
                    }
                    x = xj
                }
                j += 1
            }
            
            stores.append(SubStoreTree(edges: edges[i..<j]))
            i = j
            
            if i < edges.count {
                ranges.append(x)
            }
        }
        
        self.ranges = ranges
        self.subStores = stores
    }
    
    @inlinable
    func first(index: UInt32) -> StoreIndex {
        var i = Int(index)
        while i < subStores.count {
            let firstIndex = subStores[i].first()
            if firstIndex != .empty {
                return StoreIndex(root: UInt32(i), node: firstIndex)
            }
            i += 1
        }
        
        return StoreIndex(root: .empty, node: .empty)
    }
    
    @inlinable
    func last(index: UInt32) -> StoreIndex {
        var i = Int(index)
        while i >= 0 {
            let lastIndex = subStores[i].last()
            if lastIndex != .empty {
                return StoreIndex(root: UInt32(i), node: lastIndex)
            }
            i -= 1
        }
        
        return StoreIndex(root: .empty, node: .empty)
    }
    
    @inlinable
    func edge(_ index: StoreIndex) -> ShapeEdge {
        subStores[Int(index.root)].tree[index.node].value
    }
    
    @inlinable
    func find(xSegment: XSegment) -> StoreIndex {
        let root = self.findSubStore(x: xSegment.a.x)
        let node = self.subStores[root].find(xSegment: xSegment)
        return StoreIndex(root: UInt32(root), node: node)
    }
    
    @inlinable
    func findEqualOrNext(root: UInt32, xSegment: XSegment) -> StoreIndex {
        let node = self.subStores[Int(root)].findEqualOrNext(xSegment: xSegment)
        if node == .empty {
            return self.first(index: root + 1)
        } else {
            return StoreIndex(root: root, node: node)
        }
    }
    
    @inlinable
    mutating func removeAndNext(_ index: StoreIndex) -> StoreIndex {
        let next = self.subStores[Int(index.root)].removeAndNext(index.node)
        guard next == .empty else {
            return StoreIndex(root: index.root, node: next)
        }

        return self.first(index: index.root + 1)
    }
    
    @inlinable
    func next(_ index: StoreIndex) -> StoreIndex {
        let next = self.subStores[Int(index.root)].tree.nextByOrder(index: index.node)
        guard next == .empty else {
            return StoreIndex(root: index.root, node: next)
        }
        
        return self.first(index: index.root + 1)
    }
    
    @inlinable
    func get(_ index: StoreIndex) -> ShapeEdge {
        self.subStores[Int(index.root)].tree[index.node].value
    }
    
    @inlinable
    mutating func getAndRemove(_ index: StoreIndex) -> ShapeEdge {
        self.subStores[Int(index.root)].getAndRemove(index.node)
    }
    
    @inlinable
    mutating func remove(edge: ShapeEdge) {
        let root = self.findSubStore(x: edge.xSegment.a.x)
        self.subStores[Int(root)].remove(edge: edge)
    }
    
    @inlinable
    mutating func remove(index: StoreIndex) {
        self.subStores[Int(index.root)].remove(index: index.node)
    }
    
    @inlinable
    mutating func update(_ index: StoreIndex, count: ShapeCount) {
        self.subStores[Int(index.root)].update(index: index.node, count: count)
    }
    
    @inlinable
    mutating func addAndMerge(edge: ShapeEdge) -> StoreIndex {
        let root = self.findSubStore(x: edge.xSegment.a.x)
        
        let node = self.subStores[root].merge(edge: edge)
        return StoreIndex(root: UInt32(root), node: node)
    }
    
    private func findSubStore(x: Int32) -> Int {
        guard !ranges.isEmpty else {
            return 0
        }
        return ranges.findIndex(target: x)
    }
    
    @inlinable
    func segments() -> [Segment] {
        var result = [Segment]()
        result.reserveCapacity(subStores.count * chunkStartLength)

        for subStore in self.subStores {
            var next = subStore.tree.firstByOrder()
            while next != .empty {
                let e = subStore.tree[next].value
                if !e.count.isEmpty {
                    result.append(Segment(edge: e))
                }
                next = subStore.tree.nextByOrder(index: next)
            }
        }

        return result
    }
}
