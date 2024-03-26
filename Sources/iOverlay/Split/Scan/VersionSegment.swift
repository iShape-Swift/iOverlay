//
//  VersionSegment.swift
//  
//
//  Created by Nail Sharipov on 06.03.2024.
//

import iFixFloat

struct VersionSegment {
    let vIndex: VersionedIndex
    let xSegment: XSegment
}

extension VersionSegment: Equatable {
    public static func == (lhs: VersionSegment, rhs: VersionSegment) -> Bool {
        lhs.xSegment == rhs.xSegment && lhs.vIndex == rhs.vIndex
    }
}

extension Array where Element == VersionSegment {
    
    mutating func remove(segment: VersionSegment, scanPos: Point) {
        var j = 0
        while j < self.count {
            let seg = self[j]

            if Point.xLineCompare(a: seg.xSegment.b, b: scanPos) || segment == seg {
                self.swapRemove(j)
                continue
            }

            j += 1
        }
    }
    
}
