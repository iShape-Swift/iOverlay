//
//  EdgeStore.swift
//
//
//  Created by Nail Sharipov on 26.04.2024.
//

struct StoreIndex {
    let root: UInt32
    let node: UInt32
}

struct EdgeStore {
    
    private var ranges: [Int32]
    private var subStores: [SubStore]
    private let chunkStartLength: Int
    private let chunkListMaxSize: Int
    
    
    init(edges: [ShapeEdge], chunkStartLength: Int, chunkListMaxSize: Int) {
        // array must be sorted
        self.chunkStartLength = chunkStartLength
        self.chunkListMaxSize = chunkListMaxSize
        
        guard edges.count > chunkStartLength else {
            self.ranges = []
            self.subStores = [.list(SubStoreList(edges: edges[...]))]
            return
        }
        
        let n = edges.count / chunkStartLength
        
        var ranges = [Int32]()
        ranges.reserveCapacity(n - 1)
        
        var stores = [SubStore]()
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
            
            if j - i > chunkListMaxSize {
                stores.append(.tree(SubStoreTree(edges: edges[i..<j])))
            } else {
                stores.append(.list(SubStoreList(edges: edges[i..<j])))
            }
            
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
        let i0 = Int(index)
        let i1 = subStores.count
        for i in i0..<i1 {
            let firstIndex = subStores[i].first()
            if firstIndex != .empty {
                return StoreIndex(root: UInt32(i), node: firstIndex)
            }
        }
        
        return StoreIndex(root: .empty, node: .empty)
    }
    
    @inlinable
    func edge(_ index: StoreIndex) -> ShapeEdge {
        subStores[Int(index.root)].edge(index.node)
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
        let next = self.subStores[Int(index.root)].next(index.node)
        guard next == .empty else {
            return StoreIndex(root: index.root, node: next)
        }
        
        return self.first(index: index.root + 1)
    }
    
    @inlinable
    func get(_ index: StoreIndex) -> ShapeEdge {
        self.subStores[Int(index.root)].get(index.node)
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
        self.subStores[root].increase(maxListSize: self.chunkListMaxSize)
        
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
        if subStores.count > 1 {
            result.reserveCapacity(subStores.count * chunkStartLength)
        }

        var subIndex = self.first(index: 0)

        while subIndex.node != .empty {
            switch subStores[Int(subIndex.root)] {
            case .list(let store):
                for e in store.edges {
                    result.append(Segment(edge: e))
                }
            case .tree(let store):
                var next = store.tree.firstByOrder()
                while next != .empty {
                    let e = store.tree[next].value
                    result.append(Segment(edge: e))
                    next = store.tree.nextByOrder(index: next)
                }
            }
            subIndex = self.first(index: subIndex.root + 1)
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
