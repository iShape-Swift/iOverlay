//
//  Segment.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public typealias SegmentFill = UInt8

public extension SegmentFill {
    
    static let subjectTop: UInt8       = 0b0001
    static let subjectBottom: UInt8    = 0b0010
    static let clipTop: UInt8          = 0b0100
    static let clipBottom: UInt8       = 0b1000
    
    static let subjectBoth: UInt8 = subjectTop | subjectBottom
    static let clipBoth: UInt8 = clipTop | clipBottom
    static let bothTop: UInt8 = subjectTop | clipTop
    static let bothBottom: UInt8 = subjectBottom | clipBottom
    
    static let fillAll = subjectBoth | clipBoth

    var isFillSubject: Bool {
        self & SegmentFill.subjectBoth != 0
    }

    var isFillClip: Bool {
        self & SegmentFill.clipBoth != 0
    }

    var isFillSubjectTop: Bool {
        self & SegmentFill.subjectTop == SegmentFill.subjectTop
    }

    var isFillSubjectBottom: Bool {
        self & SegmentFill.subjectBottom == SegmentFill.subjectBottom
    }

    var isFillClipTop: Bool {
        self & SegmentFill.clipTop == SegmentFill.clipTop
    }

    var isFillClipBottom: Bool {
        self & SegmentFill.clipBottom == SegmentFill.clipBottom
    }

}

public struct Segment {

    // start < end
    public let a: FixVec        // start
    public let b: FixVec        // end
    public let count: ShapeCount
    public var fill: SegmentFill

    init(edge: ShapeEdge) {
        self.a = edge.a
        self.b = edge.b
        self.fill = 0
        self.count = edge.count
    }
}
