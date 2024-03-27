//
//  OverlayRule.swift
//
//
//  Created by Nail Sharipov on 13.08.2023.
//



/// Defines the types of overlay/boolean operations that can be applied to shapes. For a visual description, see [Overlay Rules](https://ishape-rust.github.io/iShape-js/overlay/overlay_rules.html).
/// - `subject`: Processes the subject shape, useful for resolving self-intersections and degenerate cases within the subject itself.
/// - `clip`: Similar to `Subject`, but for Clip shapes.
/// - `intersect`: Finds the common area between the subject and clip shapes, effectively identifying where they overlap.
/// - `union`: Combines the area of both subject and clip shapes into a single unified shape.
/// - `difference`: Subtracts the area of the clip shape from the subject shape, removing the clip shape's area from the subject.
/// - `xor`: Produces a shape consisting of areas unique to each shape, excluding any parts where the subject and clip overlap.
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
