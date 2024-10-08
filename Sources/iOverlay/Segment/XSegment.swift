//
//  XSegment.swift
//
//
//  Created by Nail Sharipov on 26.01.2024.
//

import iFixFloat
import iShape

public struct XSegment {
    
    public let a: Point        // start
    public let b: Point        // end

    @inline(__always)
    var yRange: LineRange {
        if a.y < b.y {
            LineRange(min: a.y, max: b.y)
        } else {
            LineRange(min: b.y, max: a.y)
        }
    }

    @inline(__always)
    var boundary: IntRect {
        IntRect(xSegment: self)
    }
    
    @inline(__always)
    var isVertical: Bool {
        a.x == b.x
    }
    
    @inline(__always)
    var isNotVertical: Bool {
        a.x != b.x
    }

    @inline(__always)
    init(a: Point, b: Point) {
        assert(a.x <= b.x)
        self.a = a
        self.b = b
    }
}

extension XSegment {
    
    /// Determines if a point `p` is under a segment
    /// - Note: This function assumes `a.x <= p.x < b.x`, and `p != a` and `p != b`.
    /// - Parameters:
    ///   - p: The point to check.
    /// - Returns: `true` if point `p` is under the segment, `false` otherwise.
    @inline(__always) func isUnder(point p: Point) -> Bool {
        assert(a.x <= p.x && p.x <= b.x)
        assert(p != a && p != b)
        return Triangle.isClockwise(p0: a, p1: p, p2: b)
    }
    
    /// Determines if first segment is under the second segment
    /// - Note: This function assumes `other.a.x < b.x`, `a.x < other.b.x`.
    /// - Parameters:
    ///   - other: second segment
    /// - Returns: `true` if point first segment is under the second segment, `false` otherwise.
    @inline(__always) func isUnder(segment other: XSegment) -> Bool {
        if a == other.a {
            return Triangle.isClockwise(p0: a, p1: other.b, p2: b)
        } else if a.x < other.a.x {
            return Triangle.isClockwise(p0: a, p1: other.a, p2: b)
        } else {
            return Triangle.isClockwise(p0: other.a, p1: other.b, p2: a)
        }
    }
    
    @inline(__always) func isLess(_ other: XSegment) -> Bool {
        if self.a == other.a {
            return self.b < other.b
        } else {
            return self.a < other.a
        }
    }
}

extension XSegment: Comparable {
    @inline(__always)
    public static func < (lhs: XSegment, rhs: XSegment) -> Bool {
        lhs.isLess(rhs)
    }
}

extension XSegment: Equatable {
    @inline(__always)
    public static func == (lhs: XSegment, rhs: XSegment) -> Bool {
        lhs.a == rhs.a && lhs.b == rhs.b
    }
}

extension IntRect {
    
    init(xSegment: XSegment) {
        let minY: Int32
        let maxY: Int32
        
        if xSegment.a.y < xSegment.b.y {
            minY = xSegment.a.y
            maxY = xSegment.b.y
        } else {
            minY = xSegment.b.y
            maxY = xSegment.a.y
        }
        
        self.init(
            minX: xSegment.a.x,
            maxX: xSegment.b.x,
            minY: minY,
            maxY: maxY
        )
    }
}
