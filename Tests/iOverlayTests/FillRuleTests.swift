//
//  FillRuleTests.swift
//
//
//  Created by Nail Sharipov on 18.12.2023.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class FillRuleTests: XCTestCase {
    
    func test_00() throws {
        let shapes = [
            self.square(pos: Point(-10, -10)),
            self.square(pos: Point(-10,   0)),
            self.square(pos: Point(-10,  10)),
            self.square(pos: Point(  0, -10)),
            self.square(pos: Point(  0,  10)),
            self.square(pos: Point( 10, -10)),
            self.square(pos: Point( 10,   0)),
            self.square(pos: Point( 10,  10))
            ]

        let simplified = shapes.simplify(fillRule: .nonZero)
        
        XCTAssertEqual(simplified.count, 1)
        XCTAssertEqual(simplified[0].count, 2)
    }
    
    
    private func square(pos: Point) -> Shape {
        let path = [
            Point(-5 + pos.x, -5 + pos.y),
            Point(-5 + pos.x,  5 + pos.y),
            Point( 5 + pos.x,  5 + pos.y),
            Point( 5 + pos.x, -5 + pos.y)
        ]
        
        return [path]
    }
}
