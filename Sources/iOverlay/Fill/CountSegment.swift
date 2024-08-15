//
//  CountSegment.swift
//  
//
//  Created by Nail Sharipov on 05.03.2024.
//

struct CountSegment {
    let count: ShapeCount
    let xSegment: XSegment
}

extension CountSegment: Comparable {
    
    @inline(__always)
    static func < (lhs: CountSegment, rhs: CountSegment) -> Bool {
        lhs.xSegment.isUnder(segment: rhs.xSegment)
    }
}

extension CountSegment: Equatable {
    
    @inline(__always)
    public static func == (lhs: CountSegment, rhs: CountSegment) -> Bool {
        lhs.xSegment == rhs.xSegment
    }
}
