//
//  CGOverlayGraph.swift
//
//
//  Created by Nail Sharipov on 07.04.2024.
//

#if canImport(CoreGraphics)
import CoreGraphics
import iShape

public struct CGOverlayGraph {

    private let graph: OverlayGraph
    private let adapter: PointAdapter

    public init(graph: OverlayGraph, adapter: PointAdapter) {
        self.graph = graph
        self.adapter = adapter
    }
    
    /// Extracts and returns shapes from the overlay graph based on the specified overlay rule and minimum area threshold.
    ///
    /// This method traverses the `OverlayGraph`, identifying and constructing shapes that meet the criteria defined by the `overlayRule`. Shapes with an area less than the specified `minArea` are excluded from the result, allowing for the filtration of negligible shapes.
    ///
    /// - Parameters:
    ///   - overlayRule: The rule determining how shapes are extracted from the overlay.
    ///   - minArea: The minimum area a shape must have to be included in the return value. This parameter helps in filtering out insignificant shapes or noise. Defaults to 0, which includes all shapes regardless of size.
    ///
    /// - Returns: An array of `CGShapes`.
    /// # Shape Representation
    /// The output is a `[[[CGPoint]]]`, where:
    /// - The outer`[CGShape]` represents a set of shapes.
    /// - Each shape `[[CGPoint]]` represents a collection of paths, where the first path is the outer boundary, and all subsequent paths are holes in this boundary.
    /// - Each path `[CGPoint]` represents a collection of points, where every two consecutive points (cyclically) make up the boundary edge of the polygon.
    ///
    /// Note: Outer boundary paths have a clockwise order, and holes have a counterclockwise order.
    public func extractShapes(overlayRule: OverlayRule, minArea: CGFloat = 0) -> CGShapes {
        let sqrScale = adapter.dirScale * adapter.dirScale
        let iArea = Int64(sqrScale * minArea)
        let shapes = graph.extractShapes(overlayRule: overlayRule, minArea: iArea)

        return shapes.toCGShapes(adapter: adapter)
    }
}
#endif
