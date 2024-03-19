//
//  ShapeEdge.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape

public struct ShapeEdge {

    static let zero = ShapeEdge(a: .zero, b: .zero, count: ShapeCount(subj: 0, clip: 0))
    public let xSegment: XSegment
    var count: ShapeCount
    
    public init(a: Point, b: Point, count: ShapeCount) {
        if Point.xLineCompare(a: a, b: b) {
            xSegment = XSegment(a: a, b: b)
        } else {
            xSegment = XSegment(a: b, b: a)
        }
        self.count = count
    }

    init(min: Point, max: Point, count: ShapeCount) {
        self.xSegment = XSegment(a: min, b: max)
        self.count = count
    }
}
