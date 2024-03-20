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
        edges.reserveCapacity(subjectPaths.count)
        self.add(paths: subjectPaths, type: .subject)
        self.add(paths: clipPaths, type: .clip)
    }
    
    public init(subjShapes: FixShapes, clipShapes: FixShapes) {
        edges = [ShapeEdge]()
        edges.reserveCapacity(subjShapes.pointsCount + clipShapes.pointsCount)
        for shape in subjShapes {
            self.add(shape: shape, type: .subject)
        }
        for shape in clipShapes {
            self.add(shape: shape, type: .clip)
        }
    }
    
    public init(subjShape: FixShape, clipShape: FixShape) {
        edges = [ShapeEdge]()
        edges.reserveCapacity(subjShape.pointsCount + clipShape.pointsCount)
        self.add(shape: subjShape, type: .subject)
        self.add(shape: clipShape, type: .clip)
    }

    public mutating func add(shapes: FixShapes, type: ShapeType) {
        for shape in shapes {
            self.add(shape: shape, type: type)
        }
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

    public func buildSegments(fillRule: FillRule, solver: Solver) -> [Segment] {
        guard !edges.isEmpty else {
            return []
        }
        
        var segments = self.prepareSegments(fillRule: fillRule, solver: solver)
        
        segments.filter()
        
        return segments
    }
    
    public func buildVectors(fillRule: FillRule, overlayRule: OverlayRule, solver: Solver = .auto) -> [VectorShape] {
        guard !edges.isEmpty else {
            return []
        }

        let graph = OverlayGraph(segments: self.prepareSegments(fillRule: fillRule, solver: solver))
        let vectors = graph.extractVectors(overlayRule: overlayRule)
        
        return vectors
    }
    
    private func prepareSegments(fillRule: FillRule, solver: Solver) -> [Segment] {
        let sortedList = edges.sorted(by: { $0.xSegment.isLess($1.xSegment) })
        var buffer = [ShapeEdge]()
        buffer.reserveCapacity(sortedList.count)
        
        var prev = ShapeEdge(a: .zero, b: .zero, count: .init(subj: 0, clip: 0))
        
        for next in sortedList {
            if prev.xSegment == next.xSegment {
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
        
        var segments: [Segment]
        if solver == .list || solver == .auto && buffer.count < 10_000 {
            segments = buffer.split(scanList: ScanSplitList(count: buffer.count))
            segments.fill(scanStore: ScanFillList(), fillRule: fillRule)
        } else {
            segments = buffer.split(scanList: ScanTree(range: range, count: buffer.count))
            segments.fill(scanStore: ScanFillTree(count: buffer.count), fillRule: fillRule)
        }

        return segments
    }
    

    public func buildGraph(fillRule: FillRule = .nonZero, solver: Solver = .auto) -> OverlayGraph {
        OverlayGraph(segments: self.buildSegments(fillRule: fillRule, solver: solver))
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
        var p0 = Point(self[i0])
        
        var yMin = p0.y
        var yMax = p0.y
        
        for i in 0..<n {
            let p1 = Point(self[i])

            yMin = Swift.min(yMin, p1.y)
            yMax = Swift.max(yMax, p1.y)
            
            let value: Int32 = Point.xLineCompare(a: p0, b: p1) ? 1 : -1
            
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

private extension Array where Element == Segment {
    
    mutating func filter() {
        var hasEmpty = false
        var i = 0
        while i < self.count {
            let fill = self[i].fill
            if fill == 0 || fill == .subjBoth || fill == .clipBoth {
                hasEmpty = true
                self.swapRemove(i)
            } else {
                i += 1
            }
        }
        
        if hasEmpty {
            self.sort(by: { $0.seg.isLess($1.seg) })
        }
    }
    
    mutating func swapRemove(_ index: Int) {
        if index < self.count - 1 {
            self[index] = self.removeLast()
        } else {
            self.removeLast()
        }
    }
}
