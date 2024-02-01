//
//  VectorTests.swift
//
//
//  Created by Nail Sharipov on 31.01.2024.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class VectorTests: XCTestCase {
    
    func test_00() throws {
        let subj = FixShape(contour: [
            FixVec(-10240, -10240),
            FixVec(-10240,  10240),
            FixVec( 10240,  10240),
            FixVec( 10240, -10240)
        ])
        let clip = FixShape(contour: [
            FixVec(-5120, -5120),
            FixVec(-5120,  5120),
            FixVec( 5120,  5120),
            FixVec( 5120, -5120)
        ])
            
        
        var overlay = Overlay(capacity: 2)
        overlay.add(shape: subj, type: .subject)
        overlay.add(shape: clip, type: .clip)

        let shapes = overlay.buildVectors(fillRule: .nonZero, overlayRule: .subject)
        
        XCTAssertEqual(shapes.count, 1)
        XCTAssertEqual(shapes[0].count, 1)
        
        let vectors = shapes[0][0]
        
        XCTAssertEqual(vectors, [
            VectorEdge(fill: 2, a: FixVec(-10240, -10240), b: FixVec(-10240,  10240)),
            VectorEdge(fill: 2, a: FixVec(-10240,  10240), b: FixVec( 10240,  10240)),
            VectorEdge(fill: 2, a: FixVec( 10240,  10240), b: FixVec( 10240, -10240)),
            VectorEdge(fill: 2, a: FixVec( 10240, -10240), b: FixVec(-10240, -10240))
        ])
    }
    
    func test_01() throws {
        let subj = FixShape(contour: [
            FixVec(-10240, -10240),
            FixVec(-10240,  10240),
            FixVec( 10240,  10240),
            FixVec( 10240, -10240)
        ])
        let clip = FixShape(contour: [
            FixVec(-5120, -5120),
            FixVec(-5120,  15360),
            FixVec( 15360,  15360),
            FixVec( 15360, -5120)
        ])
            
        
        var overlay = Overlay(capacity: 2)
        overlay.add(shape: subj, type: .subject)
        overlay.add(shape: clip, type: .clip)

        let shapes = overlay.buildVectors(fillRule: .nonZero, overlayRule: .subject)
        
        XCTAssertEqual(shapes.count, 1)
        XCTAssertEqual(shapes[0].count, 1)
        
        let vectors = shapes[0][0]
        
        XCTAssertEqual(vectors, [
            VectorEdge(fill: 2, a: FixVec(-10240, -10240), b: FixVec(-10240,  10240)),
            VectorEdge(fill: 2, a: FixVec(-10240,  10240), b: FixVec( -5120,  10240)),
            VectorEdge(fill:14, a: FixVec( -5120,  10240), b: FixVec( 10240,  10240)),
            
            VectorEdge(fill:14, a: FixVec( 10240,  10240), b: FixVec( 10240, -5120)),
            VectorEdge(fill: 2, a: FixVec( 10240,  -5120), b: FixVec( 10240, -10240)),
            VectorEdge(fill: 2, a: FixVec( 10240, -10240), b: FixVec(-10240, -10240)),
        ])
    }

}
