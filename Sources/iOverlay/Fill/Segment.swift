//
//  Segment.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat

public typealias SegmentFill = UInt8

public extension SegmentFill {
    
    static let subjTop: UInt8          = 0b0001
    static let subjBottom: UInt8       = 0b0010
    static let clipTop: UInt8          = 0b0100
    static let clipBottom: UInt8       = 0b1000
    
    static let subjBoth: UInt8 = subjTop | subjBottom
    static let clipBoth: UInt8 = clipTop | clipBottom
    static let bothTop: UInt8 = subjTop | clipTop
    static let bothBottom: UInt8 = subjBottom | clipBottom
    
    static let all = subjBoth | clipBoth
}

public struct Segment {

    public let seg: XSegment
    public let count: ShapeCount
    public var fill: SegmentFill

    init(edge: ShapeEdge) {
        self.seg = XSegment(a: edge.a, b: edge.b)
        self.fill = 0
        self.count = edge.count
    }
}
