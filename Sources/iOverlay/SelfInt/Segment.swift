//
//  Segment.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public struct Segment {
    
    @usableFromInline
    static let zero = Segment(a: .zero, b: .zero, shapeMask: .empty)
    
    @inlinable
    var edge: FixEdge { FixEdge(e0: a, e1: b) }
    
    @inlinable
    var bound: FixBnd { FixBnd(p0: a, p1: b) }
    
    // start < end
    public let a: FixVec        // start
    public let b: FixVec        // end
    public let m: ShapeMask
    
    @inlinable
    init(a: FixVec, b: FixVec, shapeMask: ShapeMask) {
        self.a = a
        self.b = b
        self.m = shapeMask
    }
    
    @inlinable
    func cross(_ other: Segment) -> EdgeCross {
        edge.cross(other.edge)
    }
}

extension Segment: Equatable, Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.a == rhs.a && lhs.b == rhs.b
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(a.bitPack)
        hasher.combine(b.bitPack)
    }
    
}
