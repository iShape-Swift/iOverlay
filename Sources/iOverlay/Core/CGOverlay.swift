//
//  CGOverlay.swift
//
//
//  Created by Nail Sharipov on 07.04.2024.
//

#if canImport(CoreGraphics)
import CoreGraphics
import iShape
import iFixFloat

public struct CGOverlay {
    
    private var subjPaths: [[CGPoint]]
    private var clipPaths: [[CGPoint]]
    
    
    /// Initializes a new `CGOverlay`.
    public init() {
        subjPaths = []
        clipPaths = []
    }
    
    
    /// Initializes a new `CGOverlay` with subject and clip paths.
    ///
    /// This method allows for the direct specification of subject and clip paths, which are then processed and stored as edge data within the `CGOverlay`.
    ///
    /// - Parameters:
    ///   - subjectPaths: The paths defining the subject shape.
    ///   - clipPaths: The paths defining the clip shape.
    public init(subjectPaths: [[CGPoint]], clipPaths: [[CGPoint]]) {
        self.subjPaths = subjectPaths
        self.clipPaths = clipPaths
    }
    
   
    /// Adds multiple paths to the overlay as either subject or clip paths.
    /// - Parameters:
    ///   - paths: An array of `CGPath` instances to be added to the overlay.
    ///   - type: Specifies the role of the added paths in the overlay operation, either as `Subject` or `Clip`.
    public mutating func add(paths: [[CGPoint]], type: ShapeType) {
        switch type {
        case .subject:
            self.subjPaths.append(contentsOf: paths)
        case .clip:
            self.clipPaths.append(contentsOf: paths)
        }
    }
    
    
    /// Adds a single path to the overlay as either subject or clip paths.
    /// - Parameters:
    ///   - path: A reference to a `CGPath` instance to be added.
    ///   - type: Specifies the role of the added path in the overlay operation, either as `Subject` or `Clip`.
    public mutating func add(path: [CGPoint], type: ShapeType) {
        switch type {
        case .subject:
            self.subjPaths.append(path)
        case .clip:
            self.clipPaths.append(path)
        }
    }
    
    
    /// Constructs an `CGOverlayGraph` from the added paths or shapes using the specified fill rule. This graph is the foundation for executing boolean operations, allowing for the analysis and manipulation of the geometric data. The `OverlayGraph` created by this method represents a preprocessed state of the input shapes, optimized for the application of boolean operations based on the provided fill rule.
    /// - Parameters:
    ///   - fillRule: The fill rule to use for the shapes.
    ///   - solver: Type of solver to use.
    /// - Returns: An `CGOverlayGraph` prepared for boolean operations.
    public func buildGraph(fillRule: FillRule = .nonZero, solver: Solver = .auto) -> CGOverlayGraph {
        let subjBox = self.subjPaths.box()
        let clipBox = self.clipPaths.box()
        
        let matrix = Matrix(minMax: subjBox.union(other: clipBox))
        
        let iSubj = matrix.convertToInt(paths: self.subjPaths)
        let iClip = matrix.convertToInt(paths: self.clipPaths)
        
        let overlay = Overlay(subjectPaths: iSubj, clipPaths: iClip)
        let graph = overlay.buildGraph(fillRule: fillRule, solver: solver)
        
        return CGOverlayGraph(graph: graph, matrix: matrix)
    }
}

struct Matrix {
    
    let offset: CGPoint
    let scale: CGFloat
    let iScale: CGFloat
    
    fileprivate init(minMax: MinMax) {
        let dx = minMax.xMax - minMax.xMin
        let dy = minMax.yMax - minMax.yMin
        
        let ds = Swift.max(dx, dy)

        let l = Double(Int32.max)

        if ds > l {
            let power = Int(log2(ds / l))
            self.scale = Double(1 >> power)
        } else {
            let power = Int(log2(l / ds))
            self.scale = 1.0 / Double(1 >> power)
        }
        self.iScale = 1.0 / self.scale
        
        offset = CGPoint(x: minMax.xMin, y: minMax.yMin)
    }
    
    func convertToInt(paths: [[CGPoint]]) -> [Path] {
        var result = [[Point]]()
        result.reserveCapacity(paths.count)
        for path in paths {
            result.append(self.convertToInt(path: path))
        }
        return result
    }
    
    private func convertToInt(path: [CGPoint]) -> Path {
        var result = [Point]()
        result.reserveCapacity(path.count)
        for p in path {
            result.append(self.convertToInt(point: p))
        }
        return result
    }
    
    private func convertToInt(point p: CGPoint) -> Point {
        let x = Int32(self.scale * p.x - self.offset.x)
        let y = Int32(self.scale * p.y - self.offset.y)
        return Point(x: x, y: y)
    }
    
    func convertToFloat(paths: [[Point]]) -> [[CGPoint]] {
        var result = [[CGPoint]]()
        result.reserveCapacity(paths.count)
        for path in paths {
            result.append(self.convertToFloat(path: path))
        }
        return result
    }
    
    private func convertToFloat(path: [Point]) -> [CGPoint] {
        var result = [CGPoint]()
        result.reserveCapacity(path.count)
        for p in path {
            result.append(self.convertToFloat(point: p))
        }
        return result
    }
    
    private func convertToFloat(point p: Point) -> CGPoint {
        let x = self.iScale * CGFloat(p.x) + self.offset.x
        let y = self.iScale * CGFloat(p.y) + self.offset.y
        return CGPoint(x: x, y: y)
    }
    
    func convertToInt(area: CGFloat) -> Int64 {
        Int64(area * (self.scale * self.scale))
    }
}

private struct MinMax {
    let xMin: CGFloat
    let yMin: CGFloat
    let xMax: CGFloat
    let yMax: CGFloat
    
    func union(other: MinMax) -> MinMax {
        let xMin = Swift.min(other.xMin, self.xMin)
        let xMax = Swift.max(other.xMax, self.xMax)
        let yMin = Swift.min(other.yMin, self.yMin)
        let yMax = Swift.max(other.yMax, self.yMax)
        
        return MinMax(xMin: xMin, yMin: yMin, xMax: xMax, yMax: yMax)
    }
    
}

private extension Array where Element == [CGPoint] {

    func box() -> MinMax {
        let a = CGFloat.greatestFiniteMagnitude
        var xMin = a
        var yMin = a
        var xMax = -a
        var yMax = -a
        for path in self {
            for p in path {
                xMin = Swift.min(xMin, p.x)
                xMax = Swift.max(xMax, p.x)
                yMin = Swift.min(yMin, p.y)
                yMax = Swift.max(yMax, p.y)
            }
        }
        
        return MinMax(xMin: xMin, yMin: yMin, xMax: xMax, yMax: yMax)
    }

}

#endif
