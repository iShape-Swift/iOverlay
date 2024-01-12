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

    private var yMin: Int32 = .max
    private var yMax: Int32 = .min
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
        guard let result = path.removedDegenerates().createEdges(type: type) else {
            return
        }
        yMin = Swift.min(yMin, result.yMin)
        yMax = Swift.max(yMax, result.yMax)
        edges.append(contentsOf: result.edges)
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
        
        let range = LineRange(min: yMin, max: yMax)
        
        var segments = buffer.split(range: range)
        
        segments.fill(fillRule: fillRule, range: range)
        
        return segments
    }

    public func buildGraph(fillRule: FillRule = .nonZero) -> OverlayGraph {
        OverlayGraph(segments: self.buildSegments(fillRule: fillRule))
    }

}

private struct EdgeResult {
    let edges: [ShapeEdge]
    let yMin: Int32
    let yMax: Int32
}

private extension FixPath {
    
    func createEdges(type: ShapeType) -> EdgeResult? {
        let n = count
        guard n > 2 else {
            return nil
        }
        
        var edges = [ShapeEdge](repeating: .zero, count: n)
        
        let i0 = n - 1
        var p0 = self[i0]
        
        var yMin = p0.y
        var yMax = p0.y
        
        for i in 0..<n {
            let p1 = self[i]

            yMin = Swift.min(yMin, p1.y)
            yMax = Swift.max(yMax, p1.y)
            
            let value: Int32 = p0.bitPack <= p1.bitPack ? 1 : -1
            
            switch type {
            case .subject:
                edges[i] = ShapeEdge(a: p0, b: p1, count: ShapeCount(subj: value, clip: 0))
            case .clip:
                edges[i] = ShapeEdge(a: p0, b: p1, count: ShapeCount(subj: 0, clip: value))
            }
            
            p0 = p1
        }
        
        return EdgeResult(edges: edges, yMin: Int32(yMin), yMax: Int32(yMax))
    }
}
