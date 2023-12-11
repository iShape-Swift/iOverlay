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
            
            let isTop = fill & .subjectTop == .subjectTop
            let isBot = fill & .subjectBottom == .subjectBottom

            skip[i] = isTop == isBot
        }
        
        return skip
    }
    
    private func filterClip() -> [Bool] {
        let n = self.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = self[i].fill
            
            // Skip edge if it it inside or not belong clip
            
            let isTop = fill & .clipTop == .clipTop
            let isBot = fill & .clipBottom == .clipBottom

            skip[i] = isTop == isBot
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
            
            let subjectInner = fill == .subjectBoth
            let topOnlySubject = fill & .bothTop == .subjectTop
            let botOnlySubject = fill & .bothBottom == .subjectBottom
            
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
            
            let topOnlySubject = fill & .bothTop == .subjectTop
            let botOnlySubject = fill & .bothBottom == .subjectBottom
            let topOnlyClip = fill & .bothTop == .clipTop
            let botOnlyClip = fill & .bothBottom == .clipBottom
            let subjectInner = fill == .subjectBoth
            let clipInner = fill == .clipBoth
            let bothInner = fill == .fillAll
            
            skip[i] = !(topOnlySubject || botOnlySubject || topOnlyClip || botOnlyClip) || subjectInner || clipInner || bothInner
        }
        
        return skip
    }
}
