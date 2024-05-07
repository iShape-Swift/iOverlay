//
//  SubStore.swift
//
//
//  Created by Nail Sharipov on 05.05.2024.
//

enum SubStore {
    
    case list(SubStoreList)
    case tree(SubStoreTree)
    
    @inlinable
    func first() -> UInt32 {
        switch self {
        case .list(let store):
            store.first()
        case .tree(let store):
            store.first()
        }
    }
    
    @inlinable
    func edge(_ index: UInt32) -> ShapeEdge {
        switch self {
        case .list(let store):
            store.edges[Int(index)]
        case .tree(let store):
            store.tree[index].value
        }
    }

    @inlinable
    func find(xSegment: XSegment) -> UInt32 {
        switch self {
        case .list(let store):
            store.find(xSegment: xSegment)
        case .tree(let store):
            store.find(xSegment: xSegment)
        }
    }

    @inlinable
    func findEqualOrNext(xSegment: XSegment) -> UInt32 {
        switch self {
        case .list(let store):
            store.findEqualOrNext(xSegment: xSegment)
        case .tree(let store):
            store.findEqualOrNext(xSegment: xSegment)
        }
    }

    @inlinable
    mutating func getAndRemove(_ index: UInt32) -> ShapeEdge {
        switch self {
        case .list(var store):
            let edge = store.getAndRemove(index)
            self = .list(store)
            return edge
        case .tree(var store):
            let edge = store.getAndRemove(index)
            self = .tree(store)
            return edge
        }
    }

    @inlinable
    mutating func removeAndNext(_ rIndex: UInt32) -> UInt32 {
        switch self {
        case .list(var store):
            let index = store.removeAndNext(rIndex)
            self = .list(store)
            return index
        case .tree(var store):
            let index = store.removeAndNext(rIndex)
            self = .tree(store)
            return index
        }
    }

    @inlinable
    mutating func remove(edge: ShapeEdge) {
        switch self {
        case .list(var store):
            store.remove(edge: edge)
            self = .list(store)
        case .tree(var store):
            store.remove(edge: edge)
            self = .tree(store)
        }
    }

    @inlinable
    mutating func remove(index: UInt32) {
        switch self {
        case .list(var store):
            store.remove(index: index)
            self = .list(store)
        case .tree(var store):
            store.remove(index: index)
            self = .tree(store)
        }
    }

    @inlinable
    mutating func update(index: UInt32, count: ShapeCount) {
        switch self {
        case .list(var store):
            store.update(index: index, count: count)
            self = .list(store)
        case .tree(var store):
            store.update(index: index, count: count)
            self = .tree(store)
        }
    }

    @inlinable
    mutating func merge(edge: ShapeEdge) -> UInt32 {
        switch self {
        case .list(var store):
            let index = store.merge(edge: edge)
            self = .list(store)
            return index
        case .tree(var store):
            let index = store.merge(edge: edge)
            self = .tree(store)
            return index
        }
    }
    
    @inlinable
    func next(_ index: UInt32) -> UInt32 {
        switch self {
        case .list(let store):
            let next = index + 1
            if next < store.edges.count {
                return next
            } else {
                return .empty
            }
        case .tree(let store):
            return store.tree.nextByOrder(index: index)
        }
    }
    
    @inlinable
    func get(_ index: UInt32) -> ShapeEdge {
        switch self {
        case .list(let store):
            store.edges[Int(index)]
        case .tree(let store):
            store.tree[index].value
        }
    }
    
    @inlinable
    mutating func increase(maxListSize: Int) {
        guard case .list(let store) = self, store.edges.count > maxListSize else {
            return
        }

        self = .tree(SubStoreTree(edges: store.edges[...]))
    }
}
