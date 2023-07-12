//
//  IEdge.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

struct Segment {

    static let zero = Segment(isDirect: true, a: .zero, b: .zero)
    
    @inlinable
    var edge: FixEdge { FixEdge(e0: a, e1: b) }
    
    let isDirect: Bool
    
    // start < end
    let a: FixVec  // start
    let b: FixVec  // end

    @inlinable
    init(isDirect: Bool, a: FixVec, b: FixVec) {
        self.isDirect = isDirect
        self.a = a
        self.b = b
    }

    @inlinable
    init(a: FixVec, b: FixVec) {
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
