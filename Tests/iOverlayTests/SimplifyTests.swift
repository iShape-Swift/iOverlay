//
//  SimplifyTests.swift
//
//
//  Created by Nail Sharipov on 03.01.2024.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class SimplifyTests: XCTestCase {
    
    func test_00() throws {
        let shapes = [
            [
                [
                    Point(10614, 4421),
                    Point(10609, 4421),
                    Point(10609, 4415),
                    Point(10614, 4415)
                ]
                ]
            ]

        let simplified = shapes.simplify(fillRule: .nonZero)
        
        XCTAssertEqual(simplified.count, 1)
        XCTAssertEqual(simplified[0].count, 1)
    }

}
