//
//  XSegment+Comparable.swift
//
//
//  Created by Nail Sharipov on 25.02.2024.
//

struct TreeSegment {
    let index: Int
    let xSegment: XSegment
}

extension TreeSegment: Comparable {
    static func < (lhs: TreeSegment, rhs: TreeSegment) -> Bool {
        lhs.xSegment < rhs.xSegment
    }
}

extension TreeSegment: Equatable {
    public static func == (lhs: TreeSegment, rhs: TreeSegment) -> Bool {
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
