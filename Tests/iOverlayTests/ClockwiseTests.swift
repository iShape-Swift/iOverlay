//
//  ClockwiseTests.swift
//
//
//  Created by Nail Sharipov on 27.01.2024.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class ClockwiseTests: XCTestCase {
    
    func test_clockwise_direct() throws {
        var overlay = Overlay(capacity: 8)
        overlay.add(path: [
            FixVec(-10.0.fix, -10.0.fix),
            FixVec(-10.0.fix,  10.0.fix),
            FixVec( 10.0.fix,  10.0.fix),
            FixVec( 10.0.fix, -10.0.fix)
        ], type: .subject)

        overlay.add(path: [
            FixVec(-5.0.fix, -5.0.fix),
            FixVec(-5.0.fix, 5.0.fix),
            FixVec(5.0.fix, 5.0.fix),
            FixVec(5.0.fix, -5.0.fix),
        ], type: .clip)
        
        let graph = overlay.buildGraph(fillRule: .evenOdd)
        let shapes = graph.extractShapes(overlayRule: .difference)

        XCTAssertEqual(shapes.count, 1)

        let shape = shapes[0]
        XCTAssertEqual(shape.paths.count, 2)

        XCTAssertEqual(shape.contour.unsafeArea > 0, true)
        XCTAssertEqual(shape.paths[1].unsafeArea > 0, false)
    }
    
    func test_clockwise_reverse() throws {
        var overlay = Overlay(capacity: 8)
        overlay.add(path: [
            FixVec(-10.0.fix, -10.0.fix),
            FixVec(10.0.fix, -10.0.fix),
            FixVec(10.0.fix, 10.0.fix),
            FixVec(-10.0.fix, 10.0.fix)
        ], type: .subject)

        overlay.add(path: [
            FixVec(-5.0.fix, -5.0.fix),
            FixVec(5.0.fix, -5.0.fix),
            FixVec(5.0.fix, 5.0.fix),
            FixVec(-5.0.fix, 5.0.fix)
        ], type: .clip)
        
        let graph = overlay.buildGraph(fillRule: .evenOdd)
        let shapes = graph.extractShapes(overlayRule: .difference)

        XCTAssertEqual(shapes.count, 1)

        let shape = shapes[0]
        XCTAssertEqual(shape.paths.count, 2)

        XCTAssertEqual(shape.contour.unsafeArea > 0, true)
        XCTAssertEqual(shape.paths[1].unsafeArea > 0, false)
    }

    func test_clockwise_all_opposite() throws {
        var overlay = Overlay(capacity: 8)
        overlay.add(path: [
            FixVec(-10.0.fix, -10.0.fix),
            FixVec(10.0.fix, -10.0.fix),
            FixVec(10.0.fix, 10.0.fix),
            FixVec(-10.0.fix, 10.0.fix)
        ], type: .subject)

        overlay.add(path: [
            FixVec(-5.0.fix, -5.0.fix),
            FixVec(-5.0.fix, 5.0.fix),
            FixVec(5.0.fix, 5.0.fix),
            FixVec(5.0.fix, -5.0.fix),
        ], type: .clip)
        
        let graph = overlay.buildGraph(fillRule: .evenOdd)
        let shapes = graph.extractShapes(overlayRule: .difference)

        XCTAssertEqual(shapes.count, 1)

        let shape = shapes[0]
        XCTAssertEqual(shape.paths.count, 2)

        XCTAssertEqual(shape.contour.unsafeArea > 0, true)
        XCTAssertEqual(shape.paths[1].unsafeArea > 0, false)
    }
    
}
