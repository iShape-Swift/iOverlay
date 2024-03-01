//
//  ScanFill.swift
//
//
//  Created by Nail Sharipov on 27.02.2024.
//

import iTree
import iFixFloat

struct TreeFillSegment {
    let count: ShapeCount
    let xSegment: XSegment
}
/*
struct ScanFill {
    
    private var buffer: [UInt32]
    private var tree: RBTree<TreeFillSegment>
    
    init(capacity: Int) {
        self.tree = RBTree(empty: .init(count: .init(subj: 0, clip: 0), xSegment: .init(a: .zero, b: .zero)), capacity: capacity)
        self.buffer = [UInt32]()
        buffer.reserveCapacity(8)
    }

    mutating func underAndNearest(point: Point, stop: Int32) -> ShapeCount {
        buffer.removeAll(keepingCapacity: true)
        var index = tree.root
        var result: UInt32 = .empty
        while index != .empty {
            let node = tree[index]
            if node.value.xSegment.b.x <= stop {
                buffer.append(node.value)
            } else {
                if node.value.xSegment.isUnder(point: point) {
                    result = index
                    index = node.right
                } else {
                    index = node.left
                }
            }
        }
        
        if result == .empty {
            return ShapeCount(subj: 0, clip: 0)
        } else {
            return self[result].value.count
        }
    }
    
}
*/

extension TreeFillSegment: Comparable {
    
    @inline(__always)
    static func < (lhs: TreeFillSegment, rhs: TreeFillSegment) -> Bool {
        lhs.xSegment < rhs.xSegment
    }
}

extension TreeFillSegment: Equatable {
    
    @inline(__always)
    public static func == (lhs: TreeFillSegment, rhs: TreeFillSegment) -> Bool {
        lhs.xSegment == rhs.xSegment
    }
}

extension RBTree where T == TreeFillSegment {
    

    
}
