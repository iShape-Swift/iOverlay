//
//  FillMask.swift
//  
//
//  Created by Nail Sharipov on 28.07.2023.
//

public typealias FillMask = Int

public extension FillMask {
    
    static let subjectTop       = 0b0001
    static let subjectBottom    = 0b0010
    static let clipTop          = 0b0100
    static let clipBottom       = 0b1000

    var isFillSubject: Bool {
        self & (FillMask.subjectTop | FillMask.subjectBottom) != 0
    }

    var isFillClip: Bool {
        self & (FillMask.clipTop | FillMask.clipBottom) != 0
    }
    
    var isFillSubjectTop: Bool {
        self & FillMask.subjectTop != 0
    }

    var isFillSubjectBottom: Bool {
        self & FillMask.subjectBottom != 0
    }

    var isFillClipTop: Bool {
        self & FillMask.clipTop != 0
    }

    var isFillClipBottom: Bool {
        self & FillMask.clipBottom != 0
    }
    
}
