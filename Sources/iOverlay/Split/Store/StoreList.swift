//
//  StoreList.swift
//
//
//  Created by Nail Sharipov on 10.05.2024.
//

struct StoreList {
    
    private var ranges: [Int32]
    private var subStores: [SubStoreList]
    private let chunkStartLength: Int
    
    init(edges: [ShapeEdge], chunkStartLength: Int) {
        // array must be sorted
        self.chunkStartLength = chunkStartLength
        
        guard edges.count > chunkStartLength else {
            self.ranges = []
            self.subStores = [SubStoreList(edges: edges[...])]
            return
        }
        
        let n = edges.count / chunkStartLength
        
        var ranges = [Int32]()
        ranges.reserveCapacity(n - 1)
        
        var stores = [SubStoreList]()
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
            
            stores.append(SubStoreList(edges: edges[i..<j]))
            i = j
            
            if i < edges.count {
                ranges.append(x)
            }
        }
        
        self.ranges = ranges
        self.subStores = stores
    }
    
    func isLarge(chunkListMaxSize: Int) -> Bool {
        for subStore in subStores {
            if subStore.edges.count > chunkListMaxSize {
                return true
            }
        }
        
        return false
    }
    
    @inlinable
    func convertToTree() -> StoreTree {
        let subStores = self.subStores.map({ SubStoreTree(edges: $0.edges[...]) })
        return StoreTree(ranges: ranges, subStores: subStores, chunkStartLength: chunkStartLength)
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
        subStores[Int(index.root)].edges[Int(index.node)]
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
        self.subStores[Int(index.root)].edges[Int(index.node)]
    }
    
    @inlinable
    mutating func getAndRemove(_ index: StoreIndex) -> ShapeEdge {
        self.subStores[Int(index.root)].getAndRemove(index.node)
    }
    
    @inlinable
    mutating func remove(_ index: StoreIndex) {
        self.subStores[Int(index.root)].remove(index: index.node)
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
        let capacity = subStores.reduce(0, { $0 + $1.edges.count })
        var result = [Segment]()
        result.reserveCapacity(capacity)

        for subStore in self.subStores {
            if !subStore.edges.isEmpty {
                for e in subStore.edges {
                    result.append(Segment(edge: e))
                }
            }
        }

        return result
    }
}
