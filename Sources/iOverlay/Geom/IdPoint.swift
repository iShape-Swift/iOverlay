//
//  IdPoint.swift
//
//
//  Created by Nail Sharipov on 26.01.2024.
//

import iFixFloat

struct IdPoint {
    let id: Int
    let point: Point
    
    init(id: Int, point: FixVec) {
        self.id = id
        self.point = Point(Int32(point.x), Int32(point.y))
    }
}
