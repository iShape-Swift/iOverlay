//
//  Tree+Floor.swift
//
//
//  Created by Nail Sharipov on 26.02.2024.
//

import iTree
import iFixFloat

extension Floor: Comparable {
    static func < (lhs: Floor, rhs: Floor) -> Bool {
        lhs.seg < rhs.seg
    }
}

extension Floor: Equatable {
    public static func == (lhs: Floor, rhs: Floor) -> Bool {
        lhs.seg == rhs.seg
    }
}

extension RBTree where T == Floor {
    
    mutating func underAndNearest(point: Point, stop: Int32) -> Int {
        var index = root
        var result: UInt32 = .empty
        while index != .empty {
            let node = self[index]
            if node.value.seg.b.x <= stop {
                self.delete(index: index)
                if node.parent != .empty {
                    index = node.parent
                } else {
                    index = root
                }
            } else {
                if node.value.seg.isUnder(point: point) {
                    result = index
                    index = node.right
                } else {
                    index = node.left
                }
            }
        }

        return self[result].value.id
    }
    
}
