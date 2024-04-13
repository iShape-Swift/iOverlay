//
//  IdPoint.swift
//
//
//  Created by Nail Sharipov on 26.01.2024.
//

import iFixFloat

struct IdPoint {
    
    static let zero = IdPoint(id: 0, point: .zero)
    
    let id: Int
    let point: Point
    
    init(id: Int, point: Point) {
        self.id = id
        self.point = point
    }
}
