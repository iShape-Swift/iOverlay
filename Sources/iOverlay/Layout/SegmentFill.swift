//
//  SegmentFill.swift
//  
//
//  Created by Nail Sharipov on 28.07.2023.
//

public typealias SegmentFill = Int

public extension SegmentFill {
    
    static let subjectTop       = 0b0001
    static let subjectBottom    = 0b0010
    static let clipTop          = 0b0100
    static let clipBottom       = 0b1000

    var isFillSubject: Bool {
        self & (SegmentFill.subjectTop | SegmentFill.subjectBottom) != 0
    }

    var isFillClip: Bool {
        self & (SegmentFill.clipTop | SegmentFill.clipBottom) != 0
    }
    
    var isFillSubjectTop: Bool {
        self & SegmentFill.subjectTop != 0
    }

    var isFillSubjectBottom: Bool {
        self & SegmentFill.subjectBottom != 0
    }

    var isFillClipTop: Bool {
        self & SegmentFill.clipTop != 0
    }

    var isFillClipBottom: Bool {
        self & SegmentFill.clipBottom != 0
    }
    
}
