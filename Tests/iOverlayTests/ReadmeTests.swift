//
//  ReadmeTests.swift
//
//
//  Created by Nail Sharipov on 27.03.2024.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class ReadmeTests: XCTestCase {
    
    func test_00() throws {
        var overlay = Overlay()

        // add shape
        overlay.add(path: [
            Point(-20, -16),
            Point(-20,  16),
            Point( 20,  16),
            Point( 20, -16)
        ], type: ShapeType.subject)

        // add hole
        overlay.add(path: [
            Point(-12, -8),
            Point(-12,  8),
            Point( 12,  8),
            Point( 12, -8)
        ], type: ShapeType.subject)

        // add clip
        overlay.add(path: [
            Point(-4, -24),
            Point(-4,  24),
            Point( 4,  24),
            Point( 4, -24)
        ], type: ShapeType.clip)

        // make overlay graph
        let graph = overlay.buildGraph()

        // get union shapes
        let union = graph.extractShapes(overlayRule: OverlayRule.union)

        // get difference shapes
        let difference = graph.extractShapes(overlayRule: OverlayRule.difference)

        // get intersect shapes
        let intersect = graph.extractShapes(overlayRule: OverlayRule.intersect)

        // get exclusion shapes
        let xor = graph.extractShapes(overlayRule: OverlayRule.xor)

        // get clean shapes from subject, self intersections will be removed
        let subject = graph.extractShapes(overlayRule: OverlayRule.subject)
        
        print("union: \(union)")
        print("difference: \(difference)")
        print("intersect: \(intersect)")
        print("xor: \(xor)")
        print("subject: \(subject)")
    }
}
