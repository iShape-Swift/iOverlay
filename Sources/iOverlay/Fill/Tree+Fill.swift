//
//  Tree+Fill.swift
//  
//
//  Created by Nail Sharipov on 26.02.2024.
//

import iFixFloat
import iTree

struct TreeFillSegment {
    #if DEBUG
    let index: Int
    #endif
    let count: ShapeCount
    let xSegment: XSegment
}

extension TreeFillSegment: Comparable {
    static func < (lhs: TreeFillSegment, rhs: TreeFillSegment) -> Bool {
        lhs.xSegment < rhs.xSegment
    }
}

extension TreeFillSegment: Equatable {
    public static func == (lhs: TreeFillSegment, rhs: TreeFillSegment) -> Bool {
        lhs.xSegment == rhs.xSegment
    }
}

extension XSegment: Comparable {
    public static func < (lhs: XSegment, rhs: XSegment) -> Bool {
        lhs.isUnder(segment: rhs)
    }
    
    public static func == (lhs: XSegment, rhs: XSegment) -> Bool {
        lhs.a == rhs.a && lhs.b == rhs.b
    }
}

extension RBTree where T == TreeFillSegment {
    
    mutating func underAndNearest(point: Point, stop: Int32) -> ShapeCount {
        var index = root
        var result: UInt32 = .empty
        while index != .empty {
            let node = self[index]
            if node.value.xSegment.b.x <= stop {
                self.delete(index: index)
                if node.parent != .empty {
                    index = node.parent
                } else {
                    index = root
                }
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
