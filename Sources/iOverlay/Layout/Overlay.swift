//
//  Overlay.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iShape
import iFixFloat

public enum ShapeType {
    case subject
    case clip
}

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
    
    public mutating func add(shape: FixShape, type: ShapeType) {
        self.add(paths: shape.paths, type: type)
    }
    
    public mutating func add(paths: [FixPath], type: ShapeType) {
        for path in paths {
            self.add(path: path, type: type)
        }
    }
    
    public mutating func add(path: FixPath, type: ShapeType) {
        let pathEdges = path.removedDegenerates().createEdges(type: type)
        edges.append(contentsOf: pathEdges)
    }

    public func buildSegments(fillRule: FillRule) -> [Segment] {
        guard !edges.isEmpty else {
            return []
        }
        
        let sortedList = edges.sorted(by: { $0.isLess($1) })
        var buffer = [ShapeEdge]()
        buffer.reserveCapacity(sortedList.count)
        
        var prev = ShapeEdge(a: .zero, b: .zero, count: .init(subj: 0, clip: 0))
        
        for next in sortedList {
            if prev.isEqual(next) {
                prev.count = prev.count.add(next.count)
            } else {
                if !prev.count.isEmpty {
                    buffer.append(prev)
                }
                prev = next
            }
        }

        if !prev.count.isEmpty {
            buffer.append(prev)
        }
        
        var segments = buffer.split()
        
        segments.fill(fillRule: fillRule)
        
        return segments
    }

    public func buildGraph(fillRule: FillRule = .nonZero) -> OverlayGraph {
        OverlayGraph(segments: self.buildSegments(fillRule: fillRule))
    }

}

private extension FixPath {
    
    func createEdges(type: ShapeType) -> [ShapeEdge] {
        let n = count
        guard n > 2 else {
            return []
        }
        
        var edges = [ShapeEdge](repeating: .zero, count: n)
        
        let i0 = n - 1
        var p0 = self[i0]
        
        for i in 0..<n {
            let p1 = self[i]

            let value: Int32 = p0.bitPack <= p1.bitPack ? 1 : -1
            
            switch type {
            case .subject:
                edges[i] = ShapeEdge(a: p0, b: p1, count: ShapeCount(subj: value, clip: 0))
            case .clip:
                edges[i] = ShapeEdge(a: p0, b: p1, count: ShapeCount(subj: 0, clip: value))
            }
            
            p0 = p1
        }
        
        return edges
    }
}
