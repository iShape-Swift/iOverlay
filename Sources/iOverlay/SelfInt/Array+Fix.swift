//
//  Array+Fix.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

private struct SegmentResult {
    let segments: [Segment]
    let vertices: [FixVec]
}

public extension Array where Element == FixVec {
    
    private func createSegments() -> SegmentResult {
        var segs = [Segment](repeating: .zero, count: count)

        let i0 = count - 1
        var iCounter = 0
        var map = [FixVec: Int]()
        map.reserveCapacity(count)
        
        var a = IndexPoint(index: iCounter, point: self[i0])
        map[a.point] = a.index
        iCounter += 1
        
        for i in 0..<count {
            let p = self[i]
            let index: Int
            if let j = map[p] {
                index = j
            } else {
                index = iCounter
                map[p] = iCounter
                iCounter += 1
            }
            
            let b = IndexPoint(index: index, point: p)
            segs[i] = Segment(id: i, a: a, b: b)
            a = b
        }
        
        var vertices = [FixVec](repeating: .zero, count: iCounter)
        for item in map {
            vertices[item.value] = item.key
        }

        return SegmentResult(segments: segs, vertices: vertices)
    }
    
    func split() -> [FixVec] {
        let clean = self.removedDegenerates()
        guard clean.count > 2 else {
            return []
        }
        let segRes = clean.createSegments()
        let splitRes = segRes.segments.split(pointsCount: segRes.vertices.count)
        
        var vertices = segRes.vertices
        for _ in 0..<splitRes.newVerts.count {
            vertices.append(.zero)
        }

        for v in splitRes.newVerts {
            vertices[v.index] = v.point
        }

        return vertices
    }
    
    
    func graph() -> SGraph? {
        let clean = self.removedDegenerates()
        guard clean.count > 2 else {
            return nil
        }
        
        let segRes = clean.createSegments()
        let splitRes = segRes.segments.split(pointsCount: segRes.vertices.count)
        
        var vertices = segRes.vertices
        for _ in 0..<splitRes.newVerts.count {
            vertices.append(.zero)
        }

        for v in splitRes.newVerts {
            vertices[v.index] = v.point
        }
        
        return SGraph(segments: splitRes.segments, vertices: vertices)
    }

}
