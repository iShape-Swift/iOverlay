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
            self.square(pos: CGPoint(x: -10.0, y: -10.0).fix),
            self.square(pos: CGPoint(x: -10.0, y:   0.0).fix),
            self.square(pos: CGPoint(x: -10.0, y:  10.0).fix),
            self.square(pos: CGPoint(x:   0.0, y: -10.0).fix),
            self.square(pos: CGPoint(x:   0.0, y:  10.0).fix),
            self.square(pos: CGPoint(x:  10.0, y: -10.0).fix),
            self.square(pos: CGPoint(x:  10.0, y:   0.0).fix),
            self.square(pos: CGPoint(x:  10.0, y:  10.0).fix)
            ]

        let simplified = shapes.simplify(fillRule: .nonZero)
        
        XCTAssertEqual(simplified.count, 1)
        XCTAssertEqual(simplified[0].paths.count, 2)
    }
    
    
    private func square(pos: FixVec) -> FixShape {
        let path = [
            CGPoint(x: -5.0, y: -5.0).fix + pos,
            CGPoint(x: -5.0, y:  5.0).fix + pos,
            CGPoint(x:  5.0, y:  5.0).fix + pos,
            CGPoint(x:  5.0, y: -5.0).fix + pos
        ]
        
        return FixShape(contour: path)
    }
}
