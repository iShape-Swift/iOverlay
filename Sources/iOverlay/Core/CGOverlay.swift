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
        let subjRect = CGRect(shape: self.subjPaths)
        let clipRect = CGRect(shape: self.clipPaths)
        
        let unionRect = CGRect(rect0: subjRect, rect1: clipRect)
        let adapter = PointAdapter(rect: unionRect)
        
        let iSubj = self.subjPaths.toShape(adapter: adapter)
        let iClip = self.clipPaths.toShape(adapter: adapter)
        
        let overlay = Overlay(subjectPaths: iSubj, clipPaths: iClip)
        let graph = overlay.buildGraph(fillRule: fillRule, solver: solver)
        
        return CGOverlayGraph(graph: graph, adapter: adapter)
    }
}

#endif
