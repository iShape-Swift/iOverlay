//
//  Overlay.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iShape
import iFixFloat

public struct Overlay {

    public internal (set) var edges: [ShapeEdge]
    
    public init(capacity: Int = 64) {
        edges = [ShapeEdge]()
        edges.reserveCapacity(capacity)
    }

    public init(subjectPaths: [FixPath], clipPaths: [FixPath]) {
        edges = [ShapeEdge]()
        self.add(paths: subjectPaths, type: .subject)
        self.add(paths: clipPaths, type: .clip)
    }

    public mutating func add(path: FixPath, type: ShapeType) {
        let count = type == .clip ? ShapeCount(subj: 0, clip: 1) : ShapeCount(subj: 1, clip: 0)
        self.add(path: path, shapeCount: count)
    }
    
    public mutating func add(paths: [FixPath], type: ShapeType) {
        let count = type == .clip ? ShapeCount(subj: 0, clip: 1) : ShapeCount(subj: 1, clip: 0)
        self.add(paths: paths, shapeCount: count)
    }
    
    private mutating func add(paths: [FixPath], shapeCount: ShapeCount) {
        for path in paths {
            self.add(path: path, shapeCount: shapeCount)
        }
    }
    
    private mutating func add(path: FixPath, shapeCount: ShapeCount) {
        let pathEdges = path.removedDegenerates().createEdges(shapeCount: shapeCount)
        edges.append(contentsOf: pathEdges)
    }

    public mutating func buildSegments() -> [Segment] {
        guard !edges.isEmpty else {
            return []
        }
        
        let sortedList = edges.sorted(by: { $0.isLess($1) })
        edges.removeAll(keepingCapacity: true)
        
        var prev = sortedList[0]
        
        for i in 1..<sortedList.count {
            let next = sortedList[i]
            
            if prev.isEqual(next) {
                prev = prev.merge(next)
            } else {
                edges.append(prev)
                prev = next
            }
        }

        edges.append(prev)
        
        edges.split()

        var segments = [Segment]()
        segments.reserveCapacity(edges.count)

        for edge in edges {
            let isSubj = edge.count.subj % 2 == 1
            let isClip = edge.count.clip % 2 == 1
            
            if isSubj || isClip {
                let clip = isClip ? ShapeType.clip : 0
                let subj = isSubj ? ShapeType.subject : 0
                let shape = clip | subj

                let segment = Segment(
                    i: segments.count,
                    a: edge.a,
                    b: edge.b,
                    shape: shape,
                    fill: 0
                )
            
                segments.append(segment)
            }
        }
        
        segments.fill()
        
        return segments
    }

    public mutating func build() -> OverlayGraph {
        OverlayGraph(segments: self.buildSegments())
    }

}

private extension FixPath {
    
    func createEdges(shapeCount: ShapeCount) -> [ShapeEdge] {
        let n = count
        guard n > 2 else {
            return []
        }
        
        var edges = [ShapeEdge](repeating: .zero, count: n)
        
        let i0 = n - 1
        var a = self[i0]
        
        for i in 0..<n {
            let b = self[i]
            edges[i] = ShapeEdge(a: a, b: b, count: shapeCount)
            a = b
        }
        
        return edges
    }
}
