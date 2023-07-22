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
    static let zero = Segment(a: .zero, b: .zero, isFillTop: false)
    
    @inlinable
    var edge: FixEdge { FixEdge(e0: a, e1: b) }

    
    // start < end
    public let a: FixVec        // start
    public let b: FixVec        // end
    public var isFillTop: Bool
    
    @inlinable
    init(a: FixVec, b: FixVec, isFillTop: Bool) {
        self.a = a
        self.b = b
        self.isFillTop = isFillTop
    }
}
