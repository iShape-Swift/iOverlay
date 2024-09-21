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
        let subj = [
            Point(-10240, -10240),
            Point(-10240,  10240),
            Point( 10240,  10240),
            Point( 10240, -10240)
        ]
        let clip = [
            Point(-5120, -5120),
            Point(-5120,  5120),
            Point( 5120,  5120),
            Point( 5120, -5120)
        ]
            
        
        var overlay = Overlay(capacity: 2)
        overlay.add(path: subj, type: .subject)
        overlay.add(path: clip, type: .clip)

        let shapes = overlay.buildVectors(fillRule: .nonZero, overlayRule: .subject)
        
        XCTAssertEqual(shapes.count, 1)
        XCTAssertEqual(shapes[0].count, 1)
        
        let vectors = shapes[0][0]
        let template = [
            VectorEdge(
                2,
                Point(-10240, -10240),
                Point(-10240,  10240)
            ),
            VectorEdge(
                2,
                Point(-10240,  10240),
                Point(10240,  10240)
            ),
            VectorEdge(
                2,
                Point( 10240,  10240),
                Point( 10240, -10240)
            ),
            VectorEdge(
                2,
                Point( 10240, -10240),
                Point(-10240, -10240)
            )
        ]
        
        XCTAssertEqual(vectors, template)
    }
    
    func test_01() throws {
        let subj = [
            Point(-10240, -10240),
            Point(-10240,  10240),
            Point( 10240,  10240),
            Point( 10240, -10240)
        ]
        
        let clip = [
            Point(-5120, -5120),
            Point(-5120,  15360),
            Point( 15360,  15360),
            Point( 15360, -5120)
        ]
  
        
        var overlay = Overlay(capacity: 2)
        overlay.add(path: subj, type: .subject)
        overlay.add(path: clip, type: .clip)

        let shapes = overlay.buildVectors(fillRule: .nonZero, overlayRule: .subject)
        
        XCTAssertEqual(shapes.count, 1)
        XCTAssertEqual(shapes[0].count, 1)
        
        let vectors = shapes[0][0]
        
        XCTAssertEqual(vectors, [
            VectorEdge(2, Point(-10240, -10240), Point(-10240,  10240)),
            VectorEdge(2, Point(-10240,  10240), Point( -5120,  10240)),
            VectorEdge(14,Point( -5120,  10240), Point( 10240,  10240)),
            
            VectorEdge(14,Point( 10240,  10240), Point( 10240, -5120)),
            VectorEdge(2, Point( 10240,  -5120), Point( 10240, -10240)),
            VectorEdge(2, Point( 10240, -10240), Point(-10240, -10240)),
        ])
    }

}
