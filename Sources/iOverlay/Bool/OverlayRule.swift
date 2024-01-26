//
//  OverlayRule.swift
//
//
//  Created by Nail Sharipov on 13.08.2023.
//

public enum OverlayRule {
    
    case subject
    case clip
    case intersect
    case union
    case difference
    case xor
    
}

extension OverlayRule {
    
    func isFillTop(fill: SegmentFill) -> Bool {
        switch self {
        case .subject:
            return fill & SegmentFill.subjectTop == SegmentFill.subjectTop
        case .clip:
            return fill & SegmentFill.clipTop == SegmentFill.clipTop
        case .intersect:
            return fill & SegmentFill.bothTop == SegmentFill.bothTop
        case .union:
            return fill & SegmentFill.bothBottom == 0
        case .difference:
            return fill & SegmentFill.bothTop == SegmentFill.subjectTop
        case .xor:
            let isSubject = fill & SegmentFill.bothTop == SegmentFill.subjectTop
            let isClip = fill & SegmentFill.bothTop == SegmentFill.clipTop
            
            return isSubject || isClip
        }
    }

    func isFillBottom(fill: SegmentFill) -> Bool {
        switch self {
        case .subject:
            return fill & SegmentFill.subjectBottom == SegmentFill.subjectBottom
        case .clip:
            return fill & SegmentFill.clipBottom == SegmentFill.clipBottom
        case .intersect:
            return fill & SegmentFill.bothBottom == SegmentFill.bothBottom
        case .union:
            return fill & SegmentFill.bothTop == 0
        case .difference:
            return fill & SegmentFill.bothBottom == SegmentFill.subjectBottom
        case .xor:
            let isSubject = fill & SegmentFill.bothBottom == SegmentFill.subjectBottom
            let isClip = fill & SegmentFill.bothBottom == SegmentFill.clipBottom
            
            return isSubject || isClip
        }
    }
    
}
