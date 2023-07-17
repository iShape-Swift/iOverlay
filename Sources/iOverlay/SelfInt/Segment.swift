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
    static let empty = Segment(id: -1, isDirect: true, a: .zero, b: .zero)
    
    @usableFromInline
    static let zero = Segment(id: 0, isDirect: true, a: .zero, b: .zero)
    
    @inlinable
    var edge: FixEdge { FixEdge(e0: a.point, e1: b.point) }
    
    @inlinable
    var bound: FixBnd { FixBnd(p0: a.point, p1: b.point) }
    
    public let id: Int
    public let isDirect: Bool
    
    // start < end
    public let a: IndexPoint  // start
    public let b: IndexPoint  // end

    @inlinable
    init(id: Int, isDirect: Bool, a: IndexPoint, b: IndexPoint) {
        self.id = id
        self.isDirect = isDirect
        self.a = a
        self.b = b
    }

    @inlinable
    init(id: Int, a: IndexPoint, b: IndexPoint) {
        self.id = id
        isDirect = a.point.bitPack < b.point.bitPack
        if isDirect {
            self.a = a
            self.b = b
        } else {
            self.a = b
            self.b = a
        }
    }
    
    @inlinable
    func cross(_ other: Segment) -> EdgeCross {
        edge.cross(other.edge)
    }

}
