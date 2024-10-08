//
//  ScanFillTree.swift
//
//
//  Created by Nail Sharipov on 05.03.2024.
//

import iFixFloat
import iTree

struct ScanFillTree: ScanFillStore {

    private var tree: RBTree<CountSegment>
    
    init(count: Int) {
        self.tree = RBTree(empty: CountSegment(count: .init(subj: 0, clip: 0), xSegment: .init(a: .zero, b: .zero)), capacity: count.log2Sqrt)
    }
    
    mutating func insert(segment: CountSegment) {
        let stop = segment.xSegment.a.x
        var index = tree.root
        var pIndex = UInt32.empty
        var isLeft = false
        
        while index != .empty {
            let node = tree[index]
            pIndex = index
            if node.value.xSegment.b.x <= stop {
                _ = tree.delete(index: index)
                if node.parent != .empty {
                    index = node.parent
                } else {
                    index = tree.root
                    pIndex = .empty
                }
            } else {
                isLeft = segment < node.value
                if isLeft {
                    index = node.left
                } else {
                    index = node.right
                }
            }
        }

        let newIndex = tree.store.getFreeIndex()
        var newNode = tree[newIndex]
        newNode.left = .empty
        newNode.right = .empty
        newNode.color = .red
        newNode.value = segment
        newNode.parent = pIndex
        tree[newIndex] = newNode
        
        if pIndex == .empty {
            tree.root = newIndex
        } else {
            if isLeft {
                tree[pIndex].left = newIndex
            } else {
                tree[pIndex].right = newIndex
            }
            
            if tree[pIndex].color == .red {
                tree.fixRedBlackPropertiesAfterInsert(nIndex: newIndex, pIndex: pIndex)
            }
        }
    }
    
    mutating func underAndNearest(point p: Point) -> ShapeCount? {
        var index = tree.root
        var result: UInt32 = .empty
        while index != .empty {
            let node = tree[index]
            if node.value.xSegment.b.x <= p.x {
                _ = tree.delete(index: index)
                if node.parent != .empty {
                    index = node.parent
                } else {
                    index = tree.root
                }
            } else {
                if node.value.xSegment.isUnder(point: p) {
                    result = index
                    index = node.right
                } else {
                    index = node.left
                }
            }
        }
        
        if result == .empty {
            return nil
        } else {
            return tree[result].value.count
        }
    }
}
