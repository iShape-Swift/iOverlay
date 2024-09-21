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
    var isDirect: Bool {
        self.a.point < self.b.point
    }

    @inline(__always)
    func other(_ nodeId: Int) -> IdPoint {
        a.id == nodeId ? b : a
    }
}
