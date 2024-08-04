//
//  SpaceLayoutTests.swift
//
//
//  Created by Nail Sharipov on 21.07.2024.
//

import XCTest
import iFixFloat
import iTree
@testable import iOverlay


final class SpaceLayoutTests: XCTestCase {
    
    func test_00() throws {
        let layout = SpaceLayout(height: Int(LineRange(min: 0, max: 7).width), count: 8)
        
        var buffer = [Fragment]()
        let xSegment = XSegment(a: Point(0, 0), b: Point(3, 5))
        
        layout.breakIntoFragments(
            index: 0,
            xSegment: xSegment,
            buffer: &buffer
        )
        
        XCTAssertFalse(buffer.isEmpty)
        validate(xSegment: xSegment, buffer: buffer)
    }
    
    func test_01() throws {
        let layout = SpaceLayout(height: Int(LineRange(min: 0, max: 7).width), count: 8)
        
        var buffer = [Fragment]()
        let xSegment = XSegment(a: Point(0, 0), b: Point(3, 6))
        
        layout.breakIntoFragments(
            index: 0,
            xSegment: xSegment,
            buffer: &buffer
        )
        
        XCTAssertFalse(buffer.isEmpty)
        validate(xSegment: xSegment, buffer: buffer)
    }
    
    func test_02() throws {
        let layout = SpaceLayout(height: Int(LineRange(min: 0, max: 7).width), count: 8)
        
        var buffer = [Fragment]()
        let xSegment = XSegment(a: Point(0, 0), b: Point(5, 3))
        
        layout.breakIntoFragments(
            index: 0,
            xSegment: xSegment,
            buffer: &buffer
        )
        
        XCTAssertFalse(buffer.isEmpty)
        validate(xSegment: xSegment, buffer: buffer)
    }
    
    func test_03() throws {
        let layout = SpaceLayout(height: Int(LineRange(min: 0, max: 7).width), count: 8)
        
        var buffer = [Fragment]()
        let xSegment = XSegment(a: Point(0, 0), b: Point(6, 3))
        
        layout.breakIntoFragments(
            index: 0,
            xSegment: xSegment,
            buffer: &buffer
        )
        
        XCTAssertFalse(buffer.isEmpty)
        validate(xSegment: xSegment, buffer: buffer)
    }
    
    func test_04() throws {
        let layout = SpaceLayout(height: Int(LineRange(min: -10, max: 0).width), count: 8)
        
        var buffer = [Fragment]()
        let xSegment = XSegment(a: Point(-1, -1), b: Point(6, -5))
        
        layout.breakIntoFragments(
            index: 0,
            xSegment: xSegment,
            buffer: &buffer
        )
        
        XCTAssertFalse(buffer.isEmpty)
        validate(xSegment: xSegment, buffer: buffer)
    }
    
    func test_05() {
        let layout = SpaceLayout(height: Int(LineRange(min: -10, max: 0).width), count: 128)
        XCTAssert(layout.minSize > 0)
    }
    
    func test_dynamic() {

        var buffer = [Fragment]()
        let a: Int32 = 32
        let range = -a...a
        
        for minY in range {
            var maxY = minY + 10
            while maxY < a {

                let yRange = minY..<maxY
                var count = 8
                while count < 1000_000 {
                    let layout = SpaceLayout(height: Int(LineRange(min: minY, max: maxY).width), count: count)
                    
                    assert(layout.minSize > 0)

                    for _ in 0..<10 {
                        let x0 = Int32.random(in: range)
                        let x1 = Int32.random(in: range)
                        
                        let y0 = Int32.random(in: yRange)
                        let y1 = Int32.random(in: yRange)
                        
                        let a: Point
                        let b: Point
                        if x0 <= x1 {
                            a = Point(x0, y0)
                            b = Point(x1, y1)
                        } else {
                            a = Point(x1, y0)
                            b = Point(x0, y1)
                        }
                        
                        guard a != b else {
                            continue
                        }
                        
                        let xSegment = XSegment(a: a, b: b)
                        
                        buffer.removeAll(keepingCapacity: true)
                        layout.breakIntoFragments(index: 0, xSegment: xSegment, buffer: &buffer)
                        
                        if !buffer.isEmpty {
                            validate(xSegment: xSegment, buffer: buffer)
                        }
                    }
                    
                    count *= 2
                }
                maxY += 1
            }
        }
    }

    func validate(xSegment: XSegment, buffer: [Fragment]) {
        for fragment in buffer {
            let rect = fragment.rect
            let topA = Point(rect.minX, rect.maxY)
            let topB = Point(rect.maxX, rect.maxY)
            let bottomA = Point(rect.minX, rect.minY)
            let bottomB = Point(rect.maxX, rect.minY)

            let isTopA = Triangle.isCW_or_Line(p0: xSegment.a, p1: topA, p2: xSegment.b)
            let isTopB = Triangle.isCW_or_Line(p0: xSegment.a, p1: topB, p2: xSegment.b)
            let isBottomA = Triangle.isCW_or_Line(p0: xSegment.a, p1: xSegment.b, p2: bottomA)
            let isBottomB = Triangle.isCW_or_Line(p0: xSegment.a, p1: xSegment.b, p2: bottomB)

            assert(isTopA && isTopB && isBottomA && isBottomB)
        }
    }

}
