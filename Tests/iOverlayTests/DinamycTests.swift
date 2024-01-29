//
//  DinamycTests.swift
//
//
//  Created by Nail Sharipov on 29.01.2024.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class DinamycTests: XCTestCase {
    
    func test_00() throws {
        var r = 0.004
        while r < 1.0 {
            for n in 5..<10 {
                let subjPaths = self.randomPolygon(radius: r, n: n)

                var overlay = Overlay(capacity: n)
                overlay.add(path: subjPaths, type: .subject)

                let graph = overlay.buildGraph(fillRule: .nonZero)
                let result = graph.extractShapes(overlayRule: .subject)

                XCTAssertTrue(!result.isEmpty)
            }
            r += 0.001
        }
    }
    
    
    func randomPolygon(radius: Double, n: Int) -> FixPath {
        var result = FixPath()
        result.reserveCapacity(n)
        let da = Double.pi * 0.7
        var a = 0.0
        for _ in 0..<n {
            let s = sin(a)
            let c = cos(a)

            let x = (radius * c).fix
            let y = (radius * s).fix

            result.append(FixVec(x, y))
            a += da
        }

        return result
    }
}
