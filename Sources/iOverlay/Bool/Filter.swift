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
        case .xor:
            return filterXOR()
        }
    }
    
    private func filterSubject() -> [Bool] {
        let n = self.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = self[i].fill
            
            // Skip edge if it it inside or not belong to subject

            let subj = fill & .subjBoth
            skip[i] = subj == 0 || subj == .subjBoth
        }
        
        return skip
    }
    
    private func filterClip() -> [Bool] {
        let n = self.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = self[i].fill
            
            // Skip edge if it it inside or not belong clip
            
            let clip = fill & .clipBoth
            skip[i] = clip == 0 || clip == .clipBoth
        }
        
        return skip
    }
    
    private func filterIntersect() -> [Bool] {
        let n = self.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = self[i].fill
            
            // One side must belong to both but not two side at once
            
            let isTop = fill & .bothTop == .bothTop
            let isBot = fill & .bothBottom == .bothBottom

            skip[i] = !(isTop || isBot) || isTop && isBot
        }
        
        return skip
    }
    
    private func filterUnion() -> [Bool] {
        let n = self.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = self[i].fill

            // One side must be empty
            
            let isTopEmpty = fill & .bothTop == 0
            let isBotEmpty = fill & .bothBottom == 0
            
            skip[i] = !(isTopEmpty || isBotEmpty)
        }
        
        return skip
    }
    
    private func filterDifference() -> [Bool] {
        let n = self.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = self[i].fill
            
            // One side must belong only subject
            // Can not be subject inner edge
            
            let subjectInner = fill == .subjBoth
            let topOnlySubject = fill & .bothTop == .subjTop
            let botOnlySubject = fill & .bothBottom == .subjBottom
            
            skip[i] = !(topOnlySubject || botOnlySubject) || subjectInner
        }
        
        return skip
    }
    
    private func filterXOR() -> [Bool] {
        let n = self.count
        var skip = [Bool](repeating: false, count: n)

        for i in 0..<n {
            let fill = self[i].fill
            
            // One side must belong only to one polygon
            // No inner sides

            let subjectInner = fill == .subjBoth
            let clipInner = fill == .clipBoth
            let bothInner = fill == .all
            let onlyTop = fill == .bothTop
            let onlyBottom = fill == .bothBottom
            let diagonal_0 = fill == .clipTop | .subjBottom
            let diagonal_1 = fill == .clipBottom | .subjTop
            
            skip[i] = subjectInner || clipInner || bothInner || onlyTop || onlyBottom || diagonal_0 || diagonal_1
        }
        
        return skip
    }
}
