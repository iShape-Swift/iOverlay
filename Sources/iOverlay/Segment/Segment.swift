//
//  Segment.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat

public typealias SegmentFill = UInt8

public extension SegmentFill {
    
    static let subjTop: UInt8          = 0b0001
    static let subjBottom: UInt8       = 0b0010
    static let clipTop: UInt8          = 0b0100
    static let clipBottom: UInt8       = 0b1000
    
    static let subjBoth: UInt8 = subjTop | subjBottom
    static let clipBoth: UInt8 = clipTop | clipBottom
    static let bothTop: UInt8 = subjTop | clipTop
    static let bothBottom: UInt8 = subjBottom | clipBottom
    
    static let all = subjBoth | clipBoth
}

public struct Segment {
    public let xSegment: XSegment
    public var count: ShapeCount
    
    static func createAndValidate(a: Point, b: Point, count: ShapeCount) -> Segment {
        if a < b {
            Segment(xSegment: XSegment(a: a, b: b), count: count)
        } else {
            Segment(xSegment: XSegment(a: b, b: a), count: count.invert())
        }
    }
}

extension Array where Element == Segment {
    mutating func mergeIfNeeded() {
        let n = self.count
        guard n > 1 else {
            return
        }

        var prev = self[0].xSegment
        for i in 1..<n {
            let this = self[i].xSegment
            if prev == this {
                self.merge(after: i)
                return
            }
            prev = this
        }
    }
    
    mutating func merge(after: Int) {
        var i = after
        var j = i - 1
        var prev = self[j]

        while i < self.count {
            if prev.xSegment == self[i].xSegment {
                prev.count = prev.count.add(self[i].count)
            } else {
                if !prev.count.isEmpty {
                    self[j] = prev
                    j += 1
                }
                prev = self[i]
            }
            i += 1
        }
        
        if !prev.count.isEmpty {
            self[j] = prev
            j += 1
        }

        self.removeLast(self.count - j)
    }
}
