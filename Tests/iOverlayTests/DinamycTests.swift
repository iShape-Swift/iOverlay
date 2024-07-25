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
                let subjPaths = self.randomPolygon(radius: r, angle: 0.0, n: n)

                var overlay = Overlay(capacity: n)
                overlay.add(path: subjPaths, type: .subject)

                let graph = overlay.buildGraph(fillRule: .nonZero)
                _ = graph.extractShapes(overlayRule: .subject)
            }
            r += 0.001
        }
    }
    
    func test_31() throws {
        let n = 100
        let subjPath = self.randomPolygon(radius: 1000.0, angle: 0.0, n: n)
        let clipPath = self.randomPolygon(radius: 1000.0, angle: 0.5, n: n)
        
        var overlay = Overlay(capacity: 2 * n)
        overlay.add(path: subjPath, type: .subject)
        overlay.add(path: clipPath, type: .clip)
        
        let graph = overlay.buildGraph(fillRule: .nonZero, solver: .list)
        let result = graph.extractShapes(overlayRule: .union)

        XCTAssertTrue(!result.isEmpty)
    }
    
    
    func randomPolygon(radius: Double, angle: Double, n: Int) -> Path {
        var result = Path()
        result.reserveCapacity(n)
        let da = 0.005
        var a = angle
        let r = radius * 1024
        for _ in 0..<n {
            let s = sin(a)
            let c = cos(a)

            let x = Int32(r * c)
            let y = Int32(r * s)

            result.append(Point(x, y))
            a += da
        }

        return result
    }
    
    func createStar(r0: Double, r1: Double, count: Int, angle: Double) -> Shape {
        let da = .pi / Double(count)
        var a = angle

        var points = [Point]()

        let ir0 = 1024 * r0
        let ir1 = 1024 * r1
        
        for _ in 0..<count {
            let xr0 = Int32(ir0 * cos(a))
            let yr0 = Int32(ir0 * sin(a))

            a += da

            let xr1 = Int32(ir1 * cos(a))
            let yr1 = Int32(ir1 * sin(a))

            a += da

            points.append(Point(xr0, yr0))
            points.append(Point(xr1, yr1))
        }

        return [points]
    }
}
