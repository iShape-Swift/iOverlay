//
//  Fragment.swift
//
//
//  Created by Nail Sharipov on 20.07.2024.
//

import iFixFloat

struct Fragment {
    let index: Int
    let rect: IntRect
    let xSegment: XSegment
    
    init(index: Int, rect: IntRect, xSegment: XSegment) {
        self.index = index
        self.rect = rect
        self.xSegment = xSegment
    }

    init(index: Int, xSegment: XSegment) {
        let minY: Int32
        let maxY: Int32
        
        if xSegment.a.y < xSegment.b.y {
            minY = xSegment.a.y
            maxY = xSegment.b.y
        } else {
            minY = xSegment.b.y
            maxY = xSegment.a.y
        }

        let rect = IntRect(
            minX: xSegment.a.x,
            maxX: xSegment.b.x,
            minY: minY,
            maxY: maxY
        )
        
        self.init(index: index, rect: rect, xSegment: xSegment)
    }
}
