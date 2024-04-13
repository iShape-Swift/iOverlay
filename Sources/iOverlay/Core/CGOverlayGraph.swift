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
    private let matrix: Matrix

    init(graph: OverlayGraph, matrix: Matrix) {
        self.graph = graph
        self.matrix = matrix
    }
    
    /// Extracts and returns shapes from the overlay graph based on the specified overlay rule and minimum area threshold.
    ///
    /// This method traverses the `OverlayGraph`, identifying and constructing shapes that meet the criteria defined by the `overlayRule`. Shapes with an area less than the specified `minArea` are excluded from the result, allowing for the filtration of negligible shapes.
    ///
    /// - Parameters:
    ///   - overlayRule: The rule determining how shapes are extracted from the overlay.
    ///   - minArea: The minimum area a shape must have to be included in the return value. This parameter helps in filtering out insignificant shapes or noise. Defaults to 0, which includes all shapes regardless of size.
    ///
    /// - Returns: An array of `[CGShape]`.
    func extractShapes(overlayRule: OverlayRule, minArea: CGFloat = 0) -> [CGShape] {
        let intArea = self.matrix.convertToInt(area: minArea)
        let intResult = graph.extractShapes(overlayRule: overlayRule, minArea: intArea)

        return intResult.map({ matrix.convertToFloat(paths: $0 ) })
    }
}
#endif
