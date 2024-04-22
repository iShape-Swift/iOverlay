//
//  FloatOverlayTests.swift
//
//
//  Created by Nail Sharipov on 21.04.2024.
//

import XCTest
import CoreGraphics
@testable import iOverlay

final class FloatOverlayTests: XCTestCase {
    
    func test_00() throws {
        var overlay = CGOverlay()

        // add first shape
        overlay.add(path: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: 1),
            CGPoint(x: 1, y: 1),
            CGPoint(x: 1, y: 0)
        ], type: ShapeType.subject)

        // add second shape
        overlay.add(path: [
            CGPoint(x: 1, y: 0),
            CGPoint(x: 1, y: 1),
            CGPoint(x: 2, y: 1),
            CGPoint(x: 2, y: 0)
        ], type: ShapeType.subject)


        // make overlay graph
        let graph = overlay.buildGraph()

        // get union shapes
        let unionShapes = graph.extractShapes(overlayRule: OverlayRule.union)
        
        XCTAssertEqual(unionShapes.count, 1)
        XCTAssertEqual(unionShapes[0].count, 1)
        XCTAssertEqual(unionShapes[0][0].count, 4)
    }
    
    func test_01() throws {
        let a = Double(1 << 30)
        
        var overlay = CGOverlay()

        // add first shape
        overlay.add(path: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: a),
            CGPoint(x: a, y: a),
            CGPoint(x: a, y: 0)
        ], type: ShapeType.subject)

        // add second shape
        overlay.add(path: [
            CGPoint(x: a, y: 0),
            CGPoint(x: a, y: a),
            CGPoint(x: 2 * a, y: a),
            CGPoint(x: 2 * a, y: 0)
        ], type: ShapeType.subject)


        // make overlay graph
        let graph = overlay.buildGraph()

        // get union shapes
        let unionShapes = graph.extractShapes(overlayRule: OverlayRule.union)
        
        XCTAssertEqual(unionShapes.count, 1)
        XCTAssertEqual(unionShapes[0].count, 1)
        XCTAssertEqual(unionShapes[0][0].count, 4)
    }
    
    func test_02() throws {
        let a = Double(1 << 48)
        
        var overlay = CGOverlay()

        // add first shape
        overlay.add(path: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: a),
            CGPoint(x: a, y: a),
            CGPoint(x: a, y: 0)
        ], type: ShapeType.subject)

        // add second shape
        overlay.add(path: [
            CGPoint(x: a, y: 0),
            CGPoint(x: a, y: a),
            CGPoint(x: 2 * a, y: a),
            CGPoint(x: 2 * a, y: 0)
        ], type: ShapeType.subject)


        // make overlay graph
        let graph = overlay.buildGraph()

        // get union shapes
        let unionShapes = graph.extractShapes(overlayRule: OverlayRule.union)
        
        XCTAssertEqual(unionShapes.count, 1)
        XCTAssertEqual(unionShapes[0].count, 1)
        XCTAssertEqual(unionShapes[0][0].count, 4)
    }
    
    func test_03() throws {
        let a = 1.0 / Double(1 << 48)
        
        var overlay = CGOverlay()

        // add first shape
        overlay.add(path: [
            CGPoint(x: 0, y: 0),
            CGPoint(x: 0, y: a),
            CGPoint(x: a, y: a),
            CGPoint(x: a, y: 0)
        ], type: ShapeType.subject)

        // add second shape
        overlay.add(path: [
            CGPoint(x: a, y: 0),
            CGPoint(x: a, y: a),
            CGPoint(x: 2 * a, y: a),
            CGPoint(x: 2 * a, y: 0)
        ], type: ShapeType.subject)


        // make overlay graph
        let graph = overlay.buildGraph()

        // get union shapes
        let unionShapes = graph.extractShapes(overlayRule: OverlayRule.union)
        
        XCTAssertEqual(unionShapes.count, 1)
        XCTAssertEqual(unionShapes[0].count, 1)
        XCTAssertEqual(unionShapes[0][0].count, 4)
    }
    
    func test_04() throws {
        let a = 0.9
        
        var overlay = CGOverlay()

        // add first shape
        overlay.add(path: [
            CGPoint(x:-a, y:-a),
            CGPoint(x:-a, y: a),
            CGPoint(x: 0, y: a),
            CGPoint(x: 0, y:-a)
        ], type: ShapeType.subject)

        // add second shape
        overlay.add(path: [
            CGPoint(x: 0, y:-a),
            CGPoint(x: 0, y: a),
            CGPoint(x: a, y: a),
            CGPoint(x: a, y:-a)
        ], type: ShapeType.subject)

        // make overlay graph
        let graph = overlay.buildGraph()

        // get union shapes
        let unionShapes = graph.extractShapes(overlayRule: OverlayRule.union)
        
        XCTAssertEqual(unionShapes.count, 1)
        XCTAssertEqual(unionShapes[0].count, 1)
        XCTAssertEqual(unionShapes[0][0].count, 4)
    }
    
    func test_05() throws {
        let a = 0.99999_99999_99999_9
        
        var overlay = CGOverlay()

        // add first shape
        overlay.add(path: [
            CGPoint(x:-a, y:-a),
            CGPoint(x:-a, y: a),
            CGPoint(x: 0, y: a),
            CGPoint(x: 0, y:-a)
        ], type: ShapeType.subject)

        // add second shape
        overlay.add(path: [
            CGPoint(x: 0, y:-a),
            CGPoint(x: 0, y: a),
            CGPoint(x: a, y: a),
            CGPoint(x: a, y:-a)
        ], type: ShapeType.subject)

        // make overlay graph
        let graph = overlay.buildGraph()

        // get union shapes
        let unionShapes = graph.extractShapes(overlayRule: OverlayRule.union)
        
        XCTAssertEqual(unionShapes.count, 1)
        XCTAssertEqual(unionShapes[0].count, 1)
        XCTAssertEqual(unionShapes[0][0].count, 4)
    }
    
    func test_06() throws {
        let a = 1.99999_99999_99999
        
        var overlay = CGOverlay()

        // add first shape
        overlay.add(path: [
            CGPoint(x:-a, y:-a),
            CGPoint(x:-a, y: a),
            CGPoint(x: 0, y: a),
            CGPoint(x: 0, y:-a)
        ], type: ShapeType.subject)

        // add second shape
        overlay.add(path: [
            CGPoint(x: 0, y:-a),
            CGPoint(x: 0, y: a),
            CGPoint(x: a, y: a),
            CGPoint(x: a, y:-a)
        ], type: ShapeType.subject)

        // make overlay graph
        let graph = overlay.buildGraph()

        // get union shapes
        let unionShapes = graph.extractShapes(overlayRule: OverlayRule.union)
        
        XCTAssertEqual(unionShapes.count, 1)
        XCTAssertEqual(unionShapes[0].count, 1)
        XCTAssertEqual(unionShapes[0][0].count, 4)
    }
    
    func test_random() throws {
        for n in 5...10 {
            var points = [CGPoint](repeating: .zero, count: n)
            for _ in 0...1000 {
                for i in 0..<n {
                    let x = CGFloat.random(in: -1...1)
                    let y = CGFloat.random(in: -1...1)
                    points[i] = CGPoint(x: x, y: y)
                }
                var overlay = CGOverlay()
                overlay.add(path: points, type: .subject)
                let graph = overlay.buildGraph()
                let shapes = graph.extractShapes(overlayRule: OverlayRule.subject)
                XCTAssertFalse(shapes.isEmpty)
            }
        }
    }
}
