//
//  IEdge.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public struct Segment {
    
    @usableFromInline
    static let zero = Segment(a: .zero, b: .zero)
    
    @inlinable
    var edge: FixEdge { FixEdge(e0: a.point, e1: b.point) }
    
    @inlinable
    var bound: FixBnd { FixBnd(p0: a.point, p1: b.point) }
    
    // start < end
    public let a: IndexPoint  // start
    public let b: IndexPoint  // end
    
    @inlinable
    init(a: IndexPoint, b: IndexPoint) {
        self.a = a
        self.b = b
    }
    
    @inlinable
    func cross(_ other: Segment) -> EdgeCross {
        edge.cross(other.edge)
    }
}

extension Segment: Equatable, Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.a.index == rhs.a.index && lhs.b.index == rhs.b.index
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(a.index)
        hasher.combine(b.index)
    }
    
}
