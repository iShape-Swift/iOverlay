//
//  IndexSegment.swift
//  
//
//  Created by Nail Sharipov on 06.03.2024.
//

import iFixFloat

extension Array where Element == XSegment {
    
    mutating func remove(segment: XSegment, scanPos: Point) {
        var j = 0
        while j < self.count {
            let seg = self[j]

            if seg.b < scanPos || segment == seg {
                self.swapRemove(j)
                continue
            }

            j += 1
        }
    }
}
