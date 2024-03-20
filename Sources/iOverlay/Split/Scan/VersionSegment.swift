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

#if DEBUG
extension VersionedIndex: Equatable {
    static func == (lhs: VersionedIndex, rhs: VersionedIndex) -> Bool {
        lhs.version == rhs.version && lhs.index == rhs.index
    }
}

extension VersionSegment: Equatable {
    public static func == (lhs: VersionSegment, rhs: VersionSegment) -> Bool {
        lhs.xSegment == rhs.xSegment && lhs.vIndex == rhs.vIndex
    }
}
#endif

extension Array where Element == VersionSegment {
    
    mutating func remove(segment: VersionSegment, scanPos: Point) {
        var j = 0
        while j < self.count {
            let seg = self[j]
            if segment == seg {
                self.swapRemove(j)
                return
            }

            if Point.xLineCompare(a: seg.xSegment.b, b: scanPos) {
                self.swapRemove(j)
                continue
            }
            
            j += 1
        }
    }
    
}
