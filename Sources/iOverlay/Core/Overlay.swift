//
//  Overlay.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iShape
import iFixFloat

/// An enumeration defining the types of shapes involved in Boolean operations.
///
/// Specifies the type of shape being processed, influencing how the shape participates in Boolean operations. This distinction is critical for understanding how shapes interact during operations like union, intersection, and subtraction.
///
/// **Note:** All operations except for `Difference` are commutative, meaning the order of `Subject` and `Clip` shapes does not impact the outcome. The `Difference` operation, on the other hand, subtracts the `Clip` shape from the `Subject`, making the order of these shapes significant.
///
/// Cases:
/// - `Subject`: The primary shape(s) for operations. Acts as the base layer in the operation.
/// - `Clip`: The modifying shape(s) that are applied to the `Subject`. Determines how the `Subject` is altered or intersected.
public enum ShapeType {
    case subject
    case clip
}

/// Represents the geometric data necessary for constructing an `OverlayGraph`, facilitating boolean operations on shapes.
///
/// This struct is crucial for preparing and uploading geometry data required by boolean operations. It serves as a container for edge data derived from shapes and paths, supporting various initializations and modifications.
public struct Overlay {

    public internal (set) var edges: [ShapeEdge]
    
    
    
    /// Initializes a new `Overlay` with a specified capacity to optimize memory and performance.
    ///
    /// This constructor is ideal for situations where the total count of edges is known beforehand, allowing for efficient memory management.
    ///
    /// - Parameter capacity: The initial storage capacity for edges. It's recommended to match or slightly exceed the expected number of edges to minimize reallocations.
    ///
    /// Example:
    /// ```
    /// let overlay = Overlay(capacity: 120) // Optimizes for up to 120 edges
    /// ```
    public init(capacity: Int = 64) {
        edges = [ShapeEdge]()
        edges.reserveCapacity(capacity)
    }
    
    
    
    /// Initializes a new `Overlay` with subject and clip paths.
    ///
    /// This method allows for the direct specification of subject and clip paths, which are then processed and stored as edge data within the `Overlay`.
    ///
    /// - Parameters:
    ///   - subjectPaths: The paths defining the subject shape.
    ///   - clipPaths: The paths defining the clip shape.
    public init(subjectPaths: [Path], clipPaths: [Path]) {
        edges = [ShapeEdge]()
        edges.reserveCapacity(subjectPaths.count)
        self.add(paths: subjectPaths, type: .subject)
        self.add(paths: clipPaths, type: .clip)
    }
    
    
    
    /// Initializes a new `Overlay` with subject and clip shapes.
    /// - Parameters:
    ///   - subjShapes: An array of shapes to be used as the subject in the overlay operation.
    ///   - clipShapes: An array of shapes to be used as the clip in the overlay operation.
    public init(subjShapes: [Shape], clipShapes: [Shape]) {
        edges = [ShapeEdge]()
        edges.reserveCapacity(subjShapes.pointsCount + clipShapes.pointsCount)
        for shape in subjShapes {
            self.add(shape: shape, type: .subject)
        }
        for shape in clipShapes {
            self.add(shape: shape, type: .clip)
        }
    }
    
    
    
    /// Initializes a new `Overlay` with subject and clip shapes.
    /// - Parameters:
    ///   - subjShape: A  shape to be used as the subject in the overlay operation.
    ///   - clipShape: A  shape to be used as the clip in the overlay operation.
    public init(subjShape: Shape, clipShape: Shape) {
        edges = [ShapeEdge]()
        edges.reserveCapacity(subjShape.pointsCount + clipShape.pointsCount)
        self.add(shape: subjShape, type: .subject)
        self.add(shape: clipShape, type: .clip)
    }
    
    
    
    /// Adds multiple shapes to the overlay as either subject or clip shapes.
    /// - Parameters:
    ///   - shapes: An array of `Shape` instances to be added to the overlay.
    ///   - type: Specifies the role of the added shapes in the overlay operation, either as `Subject` or `Clip`.
    public mutating func add(shapes: [Shape], type: ShapeType) {
        for shape in shapes {
            self.add(shape: shape, type: type)
        }
    }
    
        
    
    /// Adds a single shape to the overlay as either a subject or clip shape.
    /// - Parameters:
    ///   - shape: A reference to a `Shape` instance to be added.
    ///   - type: Specifies the role of the added shape in the overlay operation, either as `Subject` or `Clip`.
    public mutating func add(shape: Shape, type: ShapeType) {
        self.add(paths: shape, type: type)
    }
    
    
    
    /// Adds multiple paths to the overlay as either subject or clip paths.
    /// - Parameters:
    ///   - paths: An array of `Path` instances to be added to the overlay.
    ///   - type: Specifies the role of the added paths in the overlay operation, either as `Subject` or `Clip`.
    public mutating func add(paths: [Path], type: ShapeType) {
        for path in paths {
            self.add(path: path, type: type)
        }
    }

    
    
    /// Adds a single path to the overlay as either subject or clip paths.
    /// - Parameters:
    ///   - path: A reference to a `Path` instance to be added.
    ///   - type: Specifies the role of the added path in the overlay operation, either as `Subject` or `Clip`.
    public mutating func add(path: Path, type: ShapeType) {
        guard let pathEdges = path.removedDegenerates().createEdges(type: type) else {
            return
        }
        edges.append(contentsOf: pathEdges)
    }

    
    
    
    /// Constructs segments from the added paths or shapes according to the specified fill rule.
    /// - Parameters:
    ///   - fillRule: The fill rule to use when determining the inside of shapes.
    ///   - solver: Type of solver to use.
    /// - Returns: Array of segments.
    public func buildSegments(fillRule: FillRule, solver: Solver) -> [Segment] {
        guard !edges.isEmpty else {
            return []
        }
        
        var segments = self.prepareSegments(fillRule: fillRule, solver: solver)
        
        segments.filter()
        
        return segments
    }
    
    
    
    /// Constructs vector shapes from the added paths or shapes, applying the specified fill and overlay rules. This method is particularly useful for development purposes and for creating visualizations in educational demos, where understanding the impact of different rules on the final geometry is crucial.
    /// - Parameters:
    ///   - fillRule: The fill rule to use for the shapes.
    ///   - overlayRule: The overlay rule to apply.
    ///   - solver: Type of solver to use.
    /// - Returns: Array of  vector shapes.
    public func buildVectors(fillRule: FillRule, overlayRule: OverlayRule, solver: Solver = .auto) -> [VectorShape] {
        guard !edges.isEmpty else {
            return []
        }

        let graph = OverlayGraph(segments: self.prepareSegments(fillRule: fillRule, solver: solver))
        let vectors = graph.extractVectors(overlayRule: overlayRule)
        
        return vectors
    }
    
    
    
    /// Constructs an `OverlayGraph` from the added paths or shapes using the specified fill rule. This graph is the foundation for executing boolean operations, allowing for the analysis and manipulation of the geometric data. The `OverlayGraph` created by this method represents a preprocessed state of the input shapes, optimized for the application of boolean operations based on the provided fill rule.
    /// - Parameters:
    ///   - fillRule: The fill rule to use for the shapes.
    ///   - solver: Type of solver to use.
    /// - Returns: An `OverlayGraph` prepared for boolean operations.
    public func buildGraph(fillRule: FillRule = .nonZero, solver: Solver = .auto) -> OverlayGraph {
        OverlayGraph(segments: self.buildSegments(fillRule: fillRule, solver: solver))
    }
    
    private func prepareSegments(fillRule: FillRule, solver: Solver) -> [Segment] {
        var sortedEdges = edges.sorted(by: { $0.xSegment < $1.xSegment })
        
        sortedEdges.mergeIfNeeded()
        
        let isList = SplitSolver(solver: solver).split(edges: &sortedEdges)
        
        var segments = sortedEdges.segments()
        
        segments.fill(fillRule: fillRule, isList: isList)

        return segments
    }
}

private extension Path {
    
    func createEdges(type: ShapeType) -> [ShapeEdge]? {
        let n = count
        guard n > 2 else {
            return nil
        }
        
        var edges = [ShapeEdge]()
        edges.reserveCapacity(n)
        
        let i0 = n - 1
        var p0 = self[i0]
        
        for i in 0..<n {
            let p1 = self[i]
            
            let value: Int32 = p0 < p1 ? 1 : -1
            
            let edge: ShapeEdge
            switch type {
            case .subject:
                edge = ShapeEdge(a: p0, b: p1, count: ShapeCount(subj: value, clip: 0))
            case .clip:
                edge = ShapeEdge(a: p0, b: p1, count: ShapeCount(subj: 0, clip: value))
            }
            
            edges.append(edge)
            
            p0 = p1
        }
        
        return edges
    }
}

private extension Array where Element == Segment {
    
    mutating func filter() {
        var modified = false
        var i = 0
        while i < self.count {
            let fill = self[i].fill
            if fill == 0 || fill == .subjBoth || fill == .clipBoth {
                modified = true
                self.swapRemove(i)
            } else {
                i += 1
            }
        }
        
        if modified {
            self.sort(by: { $0.seg < $1.seg })
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

private extension Array where Element == ShapeEdge {
    
    func segments() -> [Segment] {
        var segments = [Segment]()
        segments.reserveCapacity(self.count)
        
        var prev = ShapeEdge(a: .zero, b: .zero, count: .init(subj: 0, clip: 0))
        
        for next in self {
            if prev.xSegment == next.xSegment {
                prev.count = prev.count.add(next.count)
            } else {
                if !prev.count.isEmpty {
                    segments.append(Segment(edge: prev))
                }
                prev = next
            }
        }

        if !prev.count.isEmpty {
            segments.append(Segment(edge: prev))
        }
        
        return segments
    }
}
