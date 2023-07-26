//
//  Segment.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public typealias SegmentFillMask = Int

public extension SegmentFillMask {
    
    static let subjectTop       = 0b0001
    static let subjectBottom    = 0b0010
    static let clipTop          = 0b0100
    static let clipBottom       = 0b1000
    
}

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
    public var fill: SegmentFillMask
    
    @inlinable
    init(i: Int, a: FixVec, b: FixVec, fill: SegmentFillMask) {
        self.i = i
        self.a = a
        self.b = b
        self.fill = fill
    }
}

extension Array where Element == Segment {
    
    func lastNodeIndex(index: Int) -> Int {
        let a = self[index].a
        var i = index + 1
        while i < count {
            if a != self[i].a {
                return i
            }
            i += 1
        }
        return i
    }

}
