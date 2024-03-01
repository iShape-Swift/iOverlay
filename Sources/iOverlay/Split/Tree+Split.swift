//
//  Tree+Split.swift
//
//
//  Created by Nail Sharipov on 27.02.2024.
//

import iTree
import iFixFloat

struct TreeSplitSegment {
    let index: VersionedIndex
    let xSegment: XSegment
}

extension TreeSplitSegment: Comparable {
    
    @inline(__always)
    static func < (lhs: TreeSplitSegment, rhs: TreeSplitSegment) -> Bool {
        lhs.xSegment < rhs.xSegment
    }
}

extension TreeSplitSegment: Equatable {
    
    @inline(__always)
    public static func == (lhs: TreeSplitSegment, rhs: TreeSplitSegment) -> Bool {
        lhs.xSegment == rhs.xSegment
    }
}
