//
//  Array+Fix.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public extension Array where Element == FixVec {
    
    private func createSegments() -> [Segment] {
        var segments = [Segment](repeating: .zero, count: count)

        let i0 = count - 1
        var a = self[i0]
        
        for i in 0..<count {
            let b = self[i]
            segments[i] = Segment(id: i, a: a, b: b)
            a = b
        }

        return segments
    }
    
    func split() -> [FixVec] {
        let clean = self.removedDegenerates()
        guard clean.count > 2 else {
            return []
        }
        let segments = clean.createSegments().split()
        return segments.vertices
    }
    
    
    func graph() -> SGraph? {
        let clean = self.removedDegenerates()
        guard clean.count > 2 else {
            return nil
        }
        
        let segments = clean.createSegments().split()
        
        return SGraph(segments: segments)
    }

}

private extension Array where Element == Segment {
    
    var vertices: [FixVec] {
        var map = [FixVec: Int]()
        var counter = 0
        for s in self {
            if map[s.a] == nil {
                map[s.a] = counter
                counter += 1
            }
            if map[s.b] == nil {
                map[s.b] = counter
                counter += 1
            }
        }

        var vertices = [FixVec](repeating: .zero, count: map.count)
        for item in map {
            vertices[item.value] = item.key
        }
        
        return vertices
    }
    
}
