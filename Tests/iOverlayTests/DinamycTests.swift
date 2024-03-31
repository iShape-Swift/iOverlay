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
        let clip = self.createStar(r0: 1.0, r1: 2.0, count: 7, angle: 0.0)
        var r = 0.95
        while r < 1.05 {
            var a = 0.0
            while a < 2.0 * .pi {
                let subj = self.createStar(r0: 1.0, r1: r, count: 7, angle: a)

                let overlay = Overlay(subjShape: subj, clipShape: clip)

                let graph = overlay.buildGraph(fillRule: .nonZero)
                let result = graph.extractShapes(overlayRule: .union)
                XCTAssertTrue(result.count > 0)
                a += 0.005
            }
            r += 0.01
        }
    }
    
    func test_10() throws {
        let n = 6
        let clip = self.createStar(r0: 1.0, r1: 2.0, count: n, angle: 0.0)
        let r = 1.0
        var a = 0.0
        while a < 2.0 * .pi {
            let subj = self.createStar(r0: 1.0, r1: r, count: n, angle: a)

            let overlay = Overlay(subjShape: subj, clipShape: clip)

            let graph = overlay.buildGraph(fillRule: .nonZero)
            let result = graph.extractShapes(overlayRule: .union)
            XCTAssertTrue(result.count > 0)
            a += 0.0003
        }
    }
    
    func test_01() throws {
        let clip = self.createStar(r0: 1.0, r1: 2.0, count: 7, angle: 0.0)
        let subj = self.createStar(r0: 1.0, r1: 1.0, count: 7, angle: 0.45000000000000029)
        let overlay = Overlay(subjShape: subj, clipShape: clip)

        let graph = overlay.buildGraph(fillRule: .nonZero)
        let result = graph.extractShapes(overlayRule: .union)
        XCTAssertTrue(result.count > 0)
    }
    

    func test_30() throws {
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
    
    func createStar(r0: Double, r1: Double, count: Int, angle: Double) -> FixShape {
        let da = .pi / Double(count)
        var a = angle

        var points = [FixVec]()

        for _ in 0..<count {
            let xr0 = r0 * cos(a)
            let yr0 = r0 * sin(a)

            a += da

            let xr1 = r1 * cos(a)
            let yr1 = r1 * sin(a)

            a += da

            points.append(FixVec(xr0.fix, yr0.fix))
            points.append(FixVec(xr1.fix, yr1.fix))
        }

        return FixShape(contour: points)
    }
}
