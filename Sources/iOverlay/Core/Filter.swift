//
//  OverlayGraph+Filter.swift
//  
//
//  Created by Nail Sharipov on 08.08.2023.
//

import iShape
import iFixFloat

extension Array where Element == OverlayLink {

    func filter(overlayRule: OverlayRule) -> [Bool] {
        switch overlayRule {
        case .subject:
            return filterSubject()
        case .clip:
            return filterClip()
        case .intersect:
            return filterIntersect()
        case .union:
            return filterUnion()
        case .difference:
            return filterDifference()
        case .inverseDifference:
            return filterInverseDifference()
        case .xor:
            return filterXOR()
        }
    }
    
    private func filterSubject() -> [Bool] {
        self.map({
            let fill = $0.fill

            // Skip edge if it inside or not belong subject

            let subj = fill & .subjBoth
            return subj == 0 || subj == .subjBoth
        })
    }
    
    private func filterClip() -> [Bool] {
        self.map({
            let fill = $0.fill
            
            // Skip edge if it it inside or not belong clip
            
            let clip = fill & .clipBoth
            return clip == 0 || clip == .clipBoth
        })
    }
    
    private func filterIntersect() -> [Bool] {
        self.map({
            let fill = $0.fill
        
            // One side must belong to both but not two side at once
            
            let isTop = fill & .bothTop == .bothTop
            let isBot = fill & .bothBottom == .bothBottom

            return !(isTop || isBot) || isTop && isBot
        })
    }
    
    private func filterUnion() -> [Bool] {
        self.map({
            let fill = $0.fill

            // One side must be empty
            
            let isTopEmpty = fill & .bothTop == 0
            let isBotEmpty = fill & .bothBottom == 0
            
            return !(isTopEmpty || isBotEmpty)
        })
    }
    
    private func filterDifference() -> [Bool] {
        self.map({
            let fill = $0.fill
            
            // One side must belong only subject
            // Can not be subject inner edge
            
            let subjectInner = fill == .subjBoth
            let topOnlySubject = fill & .bothTop == .subjTop
            let botOnlySubject = fill & .bothBottom == .subjBottom
            
            return !(topOnlySubject || botOnlySubject) || subjectInner
        })
    }
    
    private func filterInverseDifference() -> [Bool] {
        self.map({
            let fill = $0.fill
            
            // One side must belong only clip
            // Can not be clip inner edge
            
            let clipInner = fill == .clipBoth
            let topOnlyClip = fill & .bothTop == .clipTop
            let botOnlyClip = fill & .bothBottom == .clipBottom
            
            return !(topOnlyClip || botOnlyClip) || clipInner
        })
    }
    
    private func filterXOR() -> [Bool] {
        self.map({
            let fill = $0.fill
            
            // One side must belong only to one polygon
            // No inner sides

            let subjectInner = fill == .subjBoth
            let clipInner = fill == .clipBoth
            let bothInner = fill == .all
            let onlyTop = fill == .bothTop
            let onlyBottom = fill == .bothBottom
            let diagonal_0 = fill == .clipTop | .subjBottom
            let diagonal_1 = fill == .clipBottom | .subjTop
            
            return subjectInner || clipInner || bothInner || onlyTop || onlyBottom || diagonal_0 || diagonal_1
        })
    }
}
