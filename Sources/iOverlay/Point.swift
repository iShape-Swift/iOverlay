//
//  Point.swift
//
//
//  Created by Nail Sharipov on 19.03.2024.
//

import iFixFloat

extension Point {
    
    @inline(__always)
    static func xLineCompare(a: Point, b: Point) -> Bool {
        a.x < b.x || a.x == b.x && a.y < b.y
    }
    
}
