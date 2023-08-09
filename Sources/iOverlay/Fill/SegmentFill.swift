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
    
    static let subjectBoth = subjectTop | subjectBottom
    static let clipBoth = clipTop | clipBottom
    static let bothTop = subjectTop | clipTop
    static let bothBottom = subjectBottom | clipBottom
    
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
