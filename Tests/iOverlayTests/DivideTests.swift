//
//  DivideTests.swift
//  iOverlay
//
//  Created by Nail Sharipov on 27.11.2024.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class DivideTests: XCTestCase {

    func test_00() throws {
        let origin: [Point] = [
            Point(x: 0, y: 0),
            Point(x: 0, y: 2),
            Point(x: 2, y: 0),
            Point(x: 4, y: 2),
            Point(x: 4, y: 0),
            Point(x: 2, y: 0)
        ]

        guard let contours = origin.decomposeContours() else {
            XCTFail("Contours should not be nil")
            return
        }

        XCTAssertEqual(contours.count, 2)
    }

    func test_00_rotate() throws {
        let origin: [Point] = [
            Point(x: 0, y: 0),
            Point(x: 0, y: 2),
            Point(x: 2, y: 0),
            Point(x: 4, y: 2),
            Point(x: 4, y: 0),
            Point(x: 2, y: 0)
        ]

        for i in 0..<origin.count {
            let path = rotate(origin, by: i)
            guard let contours = path.decomposeContours() else {
                XCTFail("Contours should not be nil")
                return
            }

            XCTAssertEqual(contours.count, 2)
            let totalPoints = contours.reduce(0) { $0 + $1.count }
            XCTAssertEqual(totalPoints, origin.count)
        }
    }

    func test_01() throws {
        let origin: [Point] = [
            Point(x: 0, y: 0),
            Point(x: -2, y: 2),
            Point(x: 0, y: 2),
            Point(x: -2, y: 4),
            Point(x: 0, y: 4),
            Point(x: -2, y: 6),
            Point(x: 2, y: 6),
            Point(x: 0, y: 4),
            Point(x: 2, y: 4),
            Point(x: 0, y: 2),
            Point(x: 2, y: 2)
        ]

        guard let contours = origin.decomposeContours() else {
            XCTFail("Contours should not be nil")
            return
        }

        XCTAssertEqual(contours.count, 3)
    }
    
    func test_01_rotate() throws {
        let origin: [Point] = [
            Point(x: 0, y: 0),
            Point(x: -2, y: 2),
            Point(x: 0, y: 2),
            Point(x: -2, y: 4),
            Point(x: 0, y: 4),
            Point(x: -2, y: 6),
            Point(x: 2, y: 6),
            Point(x: 0, y: 4),
            Point(x: 2, y: 4),
            Point(x: 0, y: 2),
            Point(x: 2, y: 2)
        ]

        for i in 0..<origin.count {
            let path = rotate(origin, by: i)
            guard let contours = path.decomposeContours() else {
                XCTFail("Contours should not be nil")
                return
            }

            XCTAssertEqual(contours.count, 3)
            let totalPoints = contours.reduce(0) { $0 + $1.count }
            XCTAssertEqual(totalPoints, origin.count)
        }
    }

    func test_02() throws {
        let origin: [Point] = [
            Point(x: 0, y: 0),
            Point(x: -2, y: -1),
            Point(x: -2, y: 1),
            Point(x: 0, y: 0),
            Point(x: -1, y: 2),
            Point(x: 1, y: 2),
            Point(x: 0, y: 0),
            Point(x: 2, y: 1),
            Point(x: 2, y: -1),
            Point(x: 0, y: 0),
            Point(x: 1, y: -2),
            Point(x: -1, y: -2)
        ]

        guard let contours = origin.decomposeContours() else {
            XCTFail("Contours should not be nil")
            return
        }

        XCTAssertEqual(contours.count, 4)
    }
    
    func test_02_rotate() throws {
        let origin: [Point] = [
            Point(x: 0, y: 0),
            Point(x: -2, y: -1),
            Point(x: -2, y: 1),
            Point(x: 0, y: 0),
            Point(x: -1, y: 2),
            Point(x: 1, y: 2),
            Point(x: 0, y: 0),
            Point(x: 2, y: 1),
            Point(x: 2, y: -1),
            Point(x: 0, y: 0),
            Point(x: 1, y: -2),
            Point(x: -1, y: -2)
        ]

        for i in 0..<origin.count {
            let path = rotate(origin, by: i)
            guard let contours = path.decomposeContours() else {
                XCTFail("Contours should not be nil")
                return
            }

            XCTAssertEqual(contours.count, 4)
            let totalPoints = contours.reduce(0) { $0 + $1.count }
            XCTAssertEqual(totalPoints, origin.count)
        }
    }

    private func rotate(_ points: [Point], by shift: Int) -> [Point] {
        let count = points.count
        guard count > 0 else { return points }
        let shift = shift % count
        return Array(points[shift..<count] + points[0..<shift])
    }
}
