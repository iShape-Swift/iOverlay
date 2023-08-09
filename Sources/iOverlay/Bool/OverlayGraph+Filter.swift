//
//  OverlayGraph+Filter.swift
//  
//
//  Created by Nail Sharipov on 08.08.2023.
//

import iShape
import iFixFloat

extension OverlayGraph {

    func filter(operation: Operation) -> [Bool] {
        switch operation {
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
        let n = links.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = links[i].fill
            
            // Skip edge if it it inside or not belong subject
            
            let isTop = fill & .subjectTop == .subjectTop
            let isBot = fill & .subjectBottom == .subjectBottom

            skip[i] = isTop == isBot
        }
        
        return skip
    }
    
    private func filterClip() -> [Bool] {
        let n = links.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = links[i].fill
            
            // Skip edge if it it inside or not belong clip
            
            let isTop = fill & .clipTop == .clipTop
            let isBot = fill & .clipBottom == .clipBottom

            skip[i] = isTop == isBot
        }
        
        return skip
    }
    
    private func filterIntersect() -> [Bool] {
        let n = links.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = links[i].fill
            
            // Skip edge if it not from same side. If edge is inside for one polygon is ok too
            
            let isTopSubject = fill & .subjectTop == .subjectTop
            let isTopClip = fill & .clipTop == .clipTop

            let isBottomSubject = fill & .subjectBottom == .subjectBottom
            let isBottomClip = fill & .clipBottom == .clipBottom
            
            let skipEdge = !(isTopSubject && isTopClip || isBottomSubject && isBottomClip)
            
            skip[i] = skipEdge
        }
        
        return skip
    }
    
    private func filterUnion() -> [Bool] {
        let n = links.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = links[i].fill

            // Skip edge if it has polygon from both sides (subject or clip). One side must be empty
            
            let isTopNotEmpty = fill & .bothTop != 0
            let isBotNotEmpty = fill & .bothBottom != 0
            
            skip[i] = isTopNotEmpty && isBotNotEmpty
        }
        
        return skip
    }
    
    private func filterDifference() -> [Bool] {
        let n = links.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = links[i].fill
            
            // Skip edge if it does not have only subject side
            
            let topOnlySubject = fill & .bothTop == .subjectTop
            let botOnlySubject = fill & .bothBottom == .subjectBottom
            
            skip[i] = !(topOnlySubject || botOnlySubject)
        }
        
        return skip
    }
    
    private func filterXOR() -> [Bool] {
        let n = links.count
        var skip = [Bool](repeating: false, count: n)
        
        for i in 0..<n {
            let fill = links[i].fill
            
            // Every edge must have solo side and other must be empty or both fill
            
            let subjectHasSide = fill & .bothTop == .subjectTop || fill & .bothBottom == .subjectBottom
            let clipHasSide = fill & .bothTop == .clipTop || fill & .bothBottom == .clipBottom
            
            skip[i] = subjectHasSide == clipHasSide
        }
        
        return skip
    }
}
