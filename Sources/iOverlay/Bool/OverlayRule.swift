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
            return fill & SegmentFill.subjTop == SegmentFill.subjTop
        case .clip:
            return fill & SegmentFill.clipTop == SegmentFill.clipTop
        case .intersect:
            return fill & SegmentFill.bothTop == SegmentFill.bothTop
        case .union:
            return fill & SegmentFill.bothBottom == 0
        case .difference:
            return fill & SegmentFill.bothTop == SegmentFill.subjTop
        case .xor:
            let isSubject = fill & SegmentFill.bothTop == SegmentFill.subjTop
            let isClip = fill & SegmentFill.bothTop == SegmentFill.clipTop
            
            return isSubject || isClip
        }
    }
}
