//
//  Segment.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public struct Segment {
    
    @usableFromInline
    static let zero = Segment(i: 0, a: .zero, b: .zero, fill: 0)
    
    @inlinable
    var edge: FixEdge { FixEdge(e0: a, e1: b) }

    @usableFromInline
    let i: Int                  // index in store array
    
    // start < end
    public let a: FixVec        // start
    public let b: FixVec        // end
    public var fill: FillMask
    
    @inlinable
    init(i: Int, a: FixVec, b: FixVec, fill: FillMask) {
        self.i = i
        self.a = a
        self.b = b
        self.fill = fill
    }
}
