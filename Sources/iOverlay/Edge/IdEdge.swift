//
//  IdEdge.swift
//  
//
//  Created by Nail Sharipov on 23.06.2023.
//

import iFixFloat
import iShape

struct IdEdge {

    static let empty = IdEdge(id: -1, a: .zero, b: .zero)
    
    let id: Int
    
    let p0: IndexPoint
    let p1: IndexPoint
    
    // start < end
    let e0: FixVec  // start
    let e1: FixVec  // end

    @inlinable
    init(parent: IdEdge, e0: FixVec, e1: FixVec) {
        self.e0 = e0
        self.e1 = e1
        self.id = parent.id
        self.p0 = parent.p0
        self.p1 = parent.p1
    }

    @inlinable
    init(id: Int, a: IndexPoint, b: IndexPoint) {
        if a.point.bitPack < b.point.bitPack {
            self.p0 = a
            self.p1 = b
            self.e0 = a.point
            self.e1 = b.point
        } else {
            self.p0 = a
            self.p1 = b
            self.e1 = a.point
            self.e0 = b.point
        }
        self.id = id
    }

    @inlinable
    func miliStone(_ p: FixVec) -> MileStone {
        if p == p1.point {
            return MileStone(index: p1.index)
        } else if p == p0.point {
            return MileStone(index: p0.index)
        } else {
            return MileStone(index: p0.index, offset: p.sqrDistance(p0.point))
        }
    }
    
    @inlinable
    func cross(_ other: IdEdge) -> EdgeCross {
        FixEdge(e0: e0, e1: e1).cross(FixEdge(e0: other.e0, e1: other.e1))
    }

}
