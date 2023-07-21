//
//  Segment.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public typealias FillMask = Int

public extension FillMask {
    
    static let top      = 0b01
    static let bottom   = 0b10
    
}

public struct Segment {
    
    @usableFromInline
    static let zero = Segment(a: .zero, b: .zero, fill: 0)
    
    @inlinable
    var edge: FixEdge { FixEdge(e0: a, e1: b) }

    
    // start < end
    public let a: FixVec        // start
    public let b: FixVec        // end
    public var fill: FillMask
    
    @inlinable
    init(a: FixVec, b: FixVec, fill: FillMask) {
        self.a = a
        self.b = b
        self.fill = fill
    }
}
