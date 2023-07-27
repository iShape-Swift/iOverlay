//
//  SLink.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

import iFixFloat
import iShape

struct SLink {
    
    var a: IndexPoint
    var b: IndexPoint
    let fill: SegmentFillMask

    @inlinable
    func other(_ point: IndexPoint) -> IndexPoint {
        a.index == point.index ? b : a
    }
}
