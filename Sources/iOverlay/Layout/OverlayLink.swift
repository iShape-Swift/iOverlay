//
//  OverlayLink.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

import iFixFloat
import iShape

struct OverlayLink {
    
    var a: IndexPoint
    var b: IndexPoint
    let fill: FillMask

    @inlinable
    func other(_ point: IndexPoint) -> IndexPoint {
        a.index == point.index ? b : a
    }
}
