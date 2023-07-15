//
//  Array+Fix.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

private struct Path {
    var top: Segment = .empty
    var btm: Segment = .empty
    
    var topPoints: [FixVec] = []
    var btmPoints: [FixVec] = []
}

public extension Array where Element == FixVec {

    private func createSegments() -> [Segment] {
        var segs = [Segment](repeating: .zero, count: count)
        var a = self[count - 1]
        for i in 0..<count {
            let b = self[i]
            segs[i] = Segment(id: i, a: a, b: b)
            a = b
        }
        return segs
    }
    
    func split() -> [FixVec] {
        let clean = self.removedDegenerates()
        guard clean.count > 2 else {
            return []
        }
        let segs = clean.createSegments().split()
        var st = Set<FixVec>()
        for seg in segs {
            st.insert(seg.a)
            st.insert(seg.b)
        }
        
        return Array(st)
    }
    
    func fix() -> [FixShape] {
        let segments = self.split()
        
        var paths = [Path]()
        
        var i = 0
        while i < segments.count {
            let seg = segments[i]
            
            var j = 0
            while j < paths.count {
                
                
                
            }
            
            i += 1
        }
        
        
        
        
        
        
        return []
    }
    
}
//
//private enum JoinResult {
//    case joined
//    case closed
//    case skipped
//    
//}


private extension Path {
    
    func join(_ segment: Segment) -> Bool {
        if segment.a == top.a {

        }

        return false
    }
    
    
}
