//
//  ClockwiseTests.swift
//
//
//  Created by Nail Sharipov on 271.2024.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class ClockwiseTests: XCTestCase {
    
    func test_clockwise_direct() throws {
        var overlay = Overlay(capacity: 8)
        overlay.add(path: [
            Point(-10, -10),
            Point(-10,  10),
            Point( 10,  10),
            Point( 10, -10)
        ], type: .subject)

        overlay.add(path: [
            Point(-5, -5),
            Point(-5, 5),
            Point(5, 5),
            Point(5, -5),
        ], type: .clip)
        
        let graph = overlay.buildGraph(fillRule: .evenOdd)
        let shapes = graph.extractShapes(overlayRule: .difference)

        XCTAssertEqual(shapes.count, 1)

        let shape = shapes[0]
        XCTAssertEqual(shape.count, 2)

        XCTAssertEqual(shape[0].unsafeArea > 0, true)
        XCTAssertEqual(shape[1].unsafeArea > 0, false)
    }
    
    func test_clockwise_reverse() throws {
        var overlay = Overlay(capacity: 8)
        overlay.add(path: [
            Point(-10, -10),
            Point(10, -10),
            Point(10, 10),
            Point(-10, 10)
        ], type: .subject)

        overlay.add(path: [
            Point(-5, -5),
            Point(5, -5),
            Point(5, 5),
            Point(-5, 5)
        ], type: .clip)
        
        let graph = overlay.buildGraph(fillRule: .evenOdd)
        let shapes = graph.extractShapes(overlayRule: .difference)

        XCTAssertEqual(shapes.count, 1)

        let shape = shapes[0]
        XCTAssertEqual(shape.count, 2)

        XCTAssertEqual(shape[0].unsafeArea > 0, true)
        XCTAssertEqual(shape[1].unsafeArea > 0, false)
    }

    func test_clockwise_all_opposite() throws {
        var overlay = Overlay(capacity: 8)
        overlay.add(path: [
            Point(-10, -10),
            Point(10, -10),
            Point(10, 10),
            Point(-10, 10)
        ], type: .subject)

        overlay.add(path: [
            Point(-5, -5),
            Point(-5, 5),
            Point(5, 5),
            Point(5, -5),
        ], type: .clip)
        
        let graph = overlay.buildGraph(fillRule: .evenOdd)
        let shapes = graph.extractShapes(overlayRule: .difference)

        XCTAssertEqual(shapes.count, 1)

        let shape = shapes[0]
        XCTAssertEqual(shape.count, 2)

        XCTAssertEqual(shape[0].unsafeArea > 0, true)
        XCTAssertEqual(shape[1].unsafeArea > 0, false)
    }
    
}
