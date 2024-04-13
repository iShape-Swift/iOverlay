//
//  Point.swift
//
//
//  Created by Nail Sharipov on 19.03.2024.
//

import iFixFloat

extension Point: Comparable {
    public static func < (lhs: SIMD2<Scalar>, rhs: SIMD2<Scalar>) -> Bool {
        lhs.x < rhs.x || lhs.x == rhs.x && lhs.y < rhs.y
    }
}
