//
//  Segment.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public struct Segment {
    
    static let zero = Segment(i: 0, a: .zero, b: .zero, shape: 0, fill: 0)
    
    var edge: FixEdge { FixEdge(e0: a, e1: b) }

    let i: Int                  // index in store array
    
    // start < end
    public let a: FixVec        // start
    public let b: FixVec        // end
    public let shape: ShapeType
    public var fill: SegmentFill

    init(i: Int, a: FixVec, b: FixVec, shape: ShapeType, fill: SegmentFill) {
        self.i = i
        self.a = a
        self.b = b
        self.shape = shape
        self.fill = fill
    }
}
