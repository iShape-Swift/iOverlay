//
//  SubStoreTree.swift
//
//
//  Created by Nail Sharipov on 26.04.2024.
//

import iTree

struct SubStoreTree {
    
    private (set) var tree: RBTree<ShapeEdge>

    @inlinable
    init(edges: ArraySlice<ShapeEdge>) {
        let n = edges.count
        assert(n > 0)
        tree = RBTree(empty: .zero, array: edges)

    }

    @inlinable
    func first() -> UInt32 {
        self.tree.firstByOrder()
    }
    
    @inlinable
    func find(xSegment: XSegment) -> UInt32 {
        var index = tree.root
        
        while index != .empty {
            let node = tree[index]
            if node.value.xSegment == xSegment {
                return index
            }
            if xSegment.isLess(node.value.xSegment) {
                index = node.left
            } else {
                index = node.right
            }
        }
        
        return .empty
    }
    
    @inlinable
    func findEqualOrNext(xSegment: XSegment) -> UInt32 {
        var pIndex = UInt32.empty
        var index = tree.root
        while index != .empty {
            let node = tree[index]
            if node.value.xSegment == xSegment {
                return index
            }
            
            let isLeft = xSegment.isLess(node.value.xSegment)
            if isLeft {
                pIndex = index
                index = node.left
            } else {
                pIndex = index
                index = node.right
            }
        }
        
        return pIndex
    }
    
    @inlinable
    mutating func getAndRemove(_ index: UInt32) -> ShapeEdge {
        let edge = self.tree[index].value
        _ = self.tree.delete(index: index)
        return edge
    }
    
    @inlinable
    mutating func removeAndNext(_ rIndex: UInt32) -> UInt32 {
        let xSegment = self.tree[rIndex].value.xSegment
        _ = self.tree.delete(index: rIndex)

        var index = tree.root
        var result: UInt32 = .empty
        while index != .empty {
            let node = tree[index]
            if node.value.xSegment.isLess(xSegment) {
                result = index
                index = node.right
            } else {
                index = node.left
            }
        }
        
        return result
    }
    
    @inlinable
    mutating func remove(edge: ShapeEdge) {
        self.tree.delete(value: edge)
    }

    @inlinable
    mutating func remove(index: UInt32) {
        _ = self.tree.delete(index: index)
    }
    
    @inlinable
    mutating func update(index: UInt32, count: ShapeCount) {
        _ = self.tree[index].value.count = count
    }
    
    @inlinable
    mutating func merge(edge: ShapeEdge) -> UInt32 {
        var pIndex = UInt32.empty
        var index = tree.root
        var isLeft = false
        while index != .empty {
            let node = tree[index]
            if node.value.xSegment == edge.xSegment {
                let count = node.value.count.add(edge.count)
                if count.isEmpty {
                    _ = tree.delete(index: index)
                    return .empty
                } else {
                    tree[index].value.count = count
                    return index
                }
            }
            
            isLeft = edge.xSegment.isLess(node.value.xSegment)
            pIndex = index
            if isLeft {
                index = node.left
            } else {
                index = node.right
            }
        }
        
        if pIndex == .empty {
            tree.insertRoot(value: edge)
            return tree.root
        } else {
            return tree.insert(value: edge, pIndex: pIndex, isLeft: isLeft)
        }
    }
    
}
