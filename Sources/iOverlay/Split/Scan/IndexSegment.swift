//
//  IndexSegment.swift
//  
//
//  Created by Nail Sharipov on 06.03.2024.
//

import iFixFloat

struct IndexSegment {
    let tree: UInt32
    let xSegment: XSegment
    
    init(xSegment: XSegment, tree: UInt32) {
        self.xSegment = xSegment
        self.tree = tree
    }
    
}

extension IndexSegment: Equatable {
    public static func == (lhs: IndexSegment, rhs: IndexSegment) -> Bool {
        lhs.xSegment == rhs.xSegment
    }
}

extension Array where Element == IndexSegment {
    
    mutating func remove(segment: IndexSegment, scanPos: Point) {
        var j = 0
        while j < self.count {
            let seg = self[j]

            if seg.xSegment.b < scanPos || segment == seg {
                self.swapRemove(j)
                continue
            }

            j += 1
        }
    }
    
}
