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
    var edge: FixEdge { FixEdge(e0: a, e1: b) }
    
    @inlinable
    var bound: FixBnd { FixBnd(p0: a, p1: b) }
    
    public let id: Int
    public let isDirect: Bool
    
    // start < end
    public let a: FixVec  // start
    public let b: FixVec  // end

    @inlinable
    init(id: Int, isDirect: Bool, a: FixVec, b: FixVec) {
        self.id = id
        self.isDirect = isDirect
        self.a = a
        self.b = b
    }

    @inlinable
    init(id: Int, a: FixVec, b: FixVec) {
        self.id = id
        isDirect = a.bitPack < b.bitPack
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
