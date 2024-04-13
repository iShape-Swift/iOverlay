//
//  OverlayLink.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

import iShape

struct OverlayLink {
    
    var a: IdPoint
    var b: IdPoint
    let fill: SegmentFill

    @inline(__always)
    func other(_ point: IdPoint) -> IdPoint {
        a.id == point.id ? b : a
    }
}
