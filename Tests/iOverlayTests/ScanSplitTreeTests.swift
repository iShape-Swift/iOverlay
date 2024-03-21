//
//  IntervalTreeTests.swift
//
//
//  Created by Nail Sharipov on 18.03.2024.
//

import XCTest
import iFixFloat
@testable import iOverlay

final class IntervalTreeTests: XCTestCase {
        
    func test_00() throws {
        let nodes = ScanSplitTree.testInitNodes(range: LineRange(min: 0, max: 128), power: 4)
        
        XCTAssertEqual(nodes.count, 31)
    }
    
    func test_01() throws {
        let nodes = ScanSplitTree.testInitNodes(range: LineRange(min: 0, max: 128), power: 5)
        XCTAssertEqual(nodes.count, 63)
    }
    
    func test_02() throws {
        var tree = ScanSplitTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 1), b: Point(0, 127))
        tree.insert(segment: VersionSegment(vIndex: .empty, xSegment: xSeg))
        
        
        XCTAssertTrue(!tree.node(index: 0).list.isEmpty)
        XCTAssertTrue(tree.node(index: 1).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 2).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 4).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 5).list.isEmpty)
        XCTAssertTrue(tree.node(index: 6).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 8).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 9).list.isEmpty)
        XCTAssertTrue(tree.node(index:10).list.isEmpty)

        XCTAssertTrue(tree.node(index:11).list.isEmpty)

        XCTAssertTrue(!tree.node(index:12).list.isEmpty)
        XCTAssertTrue(tree.node(index:13).list.isEmpty)
        XCTAssertTrue(!tree.node(index:14).list.isEmpty)
    }
    
    func test_03() throws {
        var tree = ScanSplitTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 16), b: Point(0, 112))
        tree.insert(segment: VersionSegment(vIndex: .empty, xSegment: xSeg))
        
        
        XCTAssertTrue(tree.node(index: 0).list.isEmpty)
        XCTAssertTrue(tree.node(index: 1).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 2).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 4).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 5).list.isEmpty)
        XCTAssertTrue(tree.node(index: 6).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 8).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 9).list.isEmpty)
        XCTAssertTrue(tree.node(index:10).list.isEmpty)

        XCTAssertTrue(tree.node(index:11).list.isEmpty)

        XCTAssertTrue(!tree.node(index:12).list.isEmpty)
        XCTAssertTrue(tree.node(index:13).list.isEmpty)
        XCTAssertTrue(tree.node(index:14).list.isEmpty)
    }
    
    func test_04() throws {
        var tree = ScanSplitTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 17), b: Point(0, 111))
        tree.insert(segment: VersionSegment(vIndex: .empty, xSegment: xSeg))
        
        
        XCTAssertTrue(tree.node(index: 0).list.isEmpty)
        XCTAssertTrue(tree.node(index: 1).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 2).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 4).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 5).list.isEmpty)
        XCTAssertTrue(tree.node(index: 6).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 8).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 9).list.isEmpty)
        XCTAssertTrue(tree.node(index:10).list.isEmpty)

        XCTAssertTrue(tree.node(index:11).list.isEmpty)

        XCTAssertTrue(!tree.node(index:12).list.isEmpty)
        XCTAssertTrue(tree.node(index:13).list.isEmpty)
        XCTAssertTrue(tree.node(index:14).list.isEmpty)
    }
    
    func test_05() throws {
        var tree = ScanSplitTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 32), b: Point(0, 96))
        tree.insert(segment: VersionSegment(vIndex: .empty, xSegment: xSeg))
        
        
        XCTAssertTrue(tree.node(index: 0).list.isEmpty)
        XCTAssertTrue(tree.node(index: 1).list.isEmpty)
        XCTAssertTrue(tree.node(index: 2).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 4).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 5).list.isEmpty)
        XCTAssertTrue(tree.node(index: 6).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 8).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 9).list.isEmpty)
        XCTAssertTrue(tree.node(index:10).list.isEmpty)

        XCTAssertTrue(tree.node(index:11).list.isEmpty)

        XCTAssertTrue(tree.node(index:12).list.isEmpty)
        XCTAssertTrue(tree.node(index:13).list.isEmpty)
        XCTAssertTrue(tree.node(index:14).list.isEmpty)
    }
    
    func test_06() throws {
        var tree = ScanSplitTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 33), b: Point(0, 95))
        tree.insert(segment: VersionSegment(vIndex: .empty, xSegment: xSeg))

        XCTAssertTrue(tree.node(index: 0).list.isEmpty)
        XCTAssertTrue(tree.node(index: 1).list.isEmpty)
        XCTAssertTrue(tree.node(index: 2).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).list.isEmpty)
        
        XCTAssertTrue(!tree.node(index: 4).list.isEmpty)
        XCTAssertTrue(tree.node(index: 5).list.isEmpty)
        XCTAssertTrue(!tree.node(index: 6).list.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).list.isEmpty)
        
        XCTAssertTrue(!tree.node(index: 8).list.isEmpty)
        XCTAssertTrue(tree.node(index: 9).list.isEmpty)
        XCTAssertTrue(!tree.node(index:10).list.isEmpty)

        XCTAssertTrue(tree.node(index:11).list.isEmpty)

        XCTAssertTrue(tree.node(index:12).list.isEmpty)
        XCTAssertTrue(tree.node(index:13).list.isEmpty)
        XCTAssertTrue(tree.node(index:14).list.isEmpty)
    }
    
    func test_07() throws {
        var tree = ScanSplitTree(range: LineRange(min: -8, max: 9), power: 3)
        let version = VersionedIndex(version: 0, index: .empty)
        let scanPos = Point(0, 0)
        let a0 = Point(0, -6)
        let b0 = Point(8,  0)
        let a1 = Point(0,  3)
        let b1 = Point(8,  8)
        let vs = VersionSegment(vIndex: version, xSegment: XSegment(a: a0, b: b0))
        let xs = XSegment(a: a1, b: b1)
        
        tree.insert(segment: vs)
        let r1 = tree.intersect(this: xs, scanPos: scanPos)
        
        XCTAssertNil(r1)
        XCTAssertTrue(tree.count > 0)
    }
    
    func test_08() throws {
        let testSet = [
            XSegment(a: Point(-5, 0), b: Point(-5, 7)),
            XSegment(a: Point(-5, 1), b: Point(-4, 1)),
            XSegment(a: Point( 0, 4), b: Point( 4, 4)),
            XSegment(a: Point( 5,-8), b: Point( 7,-6))
        ]

        var result = [Point]()
        var tree = ScanSplitTree(range: testSet.range(), power: 3)
        var i = 0
        for s in testSet {
            if let res = tree.intersect(this: s, scanPos: s.a) {
                result.append(res.cross.point)
                if res.cross.type == .penetrate {
                    result.append(res.cross.second)
                }
            } else {
                let version = VersionedIndex(version: UInt32(i), index: .empty)
                let v = VersionSegment(vIndex: version, xSegment: s)
                tree.insert(segment: v)
                i += 1
            }
        }

        XCTAssertEqual(1, result.count)
    }
    
    func test_09() throws {
        let testSet = [
            XSegment(a: Point(-5, -6), b: Point(-5,  0)),
            XSegment(a: Point( 0, -7), b: Point( 7, -7)),
            XSegment(a: Point( 3, -7), b: Point( 3, -2)),
            XSegment(a: Point( 6, -7), b: Point(12, -7))
        ]

        var result = [Point]()
        var tree = ScanSplitTree(range: testSet.range(), count: testSet.count)
        var i = 0
        for s in testSet {
            if let res = tree.intersect(this: s, scanPos: s.a) {
                result.append(res.cross.point)
                if res.cross.type == .penetrate {
                    result.append(res.cross.second)
                }
            } else {
                let version = VersionedIndex(version: UInt32(i), index: .empty)
                let v = VersionSegment(vIndex: version, xSegment: s)
                tree.insert(segment: v)
                i += 1
            }
        }

        XCTAssertEqual(1, result.count)
    }
    
    func test_10() throws {
        let testSet = [
            XSegment(a: Point(-8, -1), b: Point(-3,  4)),
            XSegment(a: Point(-6,  3), b: Point(-1,  8)),
            XSegment(a: Point(-5,  4), b: Point(-1,  4)),
            XSegment(a: Point(-2, -1), b: Point(-2,  0))
        ]

        var result = [Point]()
        var tree = ScanSplitTree(range: testSet.range(), count: testSet.count)
        var i = 0
        for s in testSet {
            if let res = tree.intersect(this: s, scanPos: s.a) {
                result.append(res.cross.point)
                if res.cross.type == .penetrate {
                    result.append(res.cross.second)
                }
            } else {
                let version = VersionedIndex(version: UInt32(i), index: .empty)
                let v = VersionSegment(vIndex: version, xSegment: s)
                tree.insert(segment: v)
                i += 1
            }
        }

        XCTAssertEqual(1, result.count)
    }
    

    func test_random_intersect_0() {
        let range: ClosedRange<Int32> = -1000...1000
        var list = ScanSplitList(count: 1)
        var tree = ScanSplitTree(range: LineRange(min: range.lowerBound, max: range.upperBound), power: 5)
        let version = VersionedIndex(version: 0, index: .empty)
        let scanPos = Point(0, 0)
        for _ in 0...100_000 {
            let a0 = Point(0, Int32.random(in: range))
            let b0 = Point(8, Int32.random(in: range))
            let a1 = Point(0, Int32.random(in: range))
            let b1 = Point(8, Int32.random(in: range))
            
            let vs = VersionSegment(vIndex: version, xSegment: XSegment(a: a0, b: b0))
            let xs = XSegment(a: a1, b: b1)
            list.insert(segment: vs)
            tree.insert(segment: vs)
            
            let r0 = list.intersect(this: xs, scanPos: scanPos)
            let r1 = tree.intersect(this: xs, scanPos: scanPos)

            if (r0 == nil) != (r1 == nil) {
                print("a0: \(a0), b0: \(b0), a1: \(a1), b1: \(b1)")
                break
            }
            
            if r1 != nil {
                print("a0: \(a0), b0: \(b0), a1: \(a1), b1: \(b1)")
                break
            }
            
            if r1 == nil {
                XCTAssertTrue(tree.count > 0)
            } else {
                XCTAssertTrue(tree.count == 0)
            }

            XCTAssertEqual((r0 == nil), (r1 == nil))
            
            list.clear()
            tree.clear()
            
            XCTAssertEqual(tree.count, 0)
        }
    }
    
    func test_random_intersect_1() {
        let range: ClosedRange<Int32> = -8...8

        var list = ScanSplitList(count: 1)
        
        for _ in 0...100_000 {
            let testSet = self.test_set(range: range, count: 4)
            var result_0 = [Point]()
            var result_1 = [Point]()
            
            var tree = ScanSplitTree(range: testSet.range(), count: testSet.count)
            
            for v in testSet {
                if let res = list.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_0.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_0.append(res.cross.second)
                    }
                } else {
                    list.insert(segment: v)
                }
                
                if let res = tree.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_1.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_1.append(res.cross.second)
                    }
                } else {
                    tree.insert(segment: v)
                }
            }

            result_0.sort(by: { Point.xLineCompare(a: $0, b: $1) })
            result_1.sort(by: { Point.xLineCompare(a: $0, b: $1) })

            let isEqual = result_0 == result_1
            
            XCTAssertTrue(isEqual)
            if !isEqual {
                print("points: \(testSet.map({ $0.xSegment }))")
                break
            }
            
            list.clear()
        }
    }
    
    func test_random_intersect_2() {
        let range: ClosedRange<Int32> = -100...100

        var list = ScanSplitList(count: 1)
        
        for _ in 0...10_000 {
            let testSet = self.test_set(range: range, count: 100)
            var result_0 = [Point]()
            var result_1 = [Point]()
            
            var tree = ScanSplitTree(range: testSet.range(), count: testSet.count)
            
            for v in testSet {
                if let res = list.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_0.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_0.append(res.cross.second)
                    }
                } else {
                    list.insert(segment: v)
                }
                
                if let res = tree.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_1.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_1.append(res.cross.second)
                    }
                } else {
                    tree.insert(segment: v)
                }
            }

            result_0.sort(by: { Point.xLineCompare(a: $0, b: $1) })
            result_1.sort(by: { Point.xLineCompare(a: $0, b: $1) })

            let isEqual = result_0 == result_1

            XCTAssertTrue(isEqual)
            if !isEqual {
                print("points: \(testSet.map({ $0.xSegment }))")
                break
            }

            list.clear()
        }
    }
    
    func test_random_intersect_3() {
        let range: ClosedRange<Int32> = -100...100

        var list = ScanSplitList(count: 1)
        
        for _ in 0...10_000 {
            let testSet = self.test_set(range: range, count: 100)
            var result_0 = [Point]()
            var result_1 = [Point]()
            
            var tree = ScanSplitTree(range: testSet.range(), count: testSet.count)
            
            for v in testSet {
                if let res = list.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_0.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_0.append(res.cross.second)
                    }
                } else {
                    list.insert(segment: v)
                }
                
                if let res = tree.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_1.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_1.append(res.cross.second)
                    }
                } else {
                    tree.insert(segment: v)
                }
            }

            result_0.sort(by: { Point.xLineCompare(a: $0, b: $1) })
            result_1.sort(by: { Point.xLineCompare(a: $0, b: $1) })

            let isEqual = result_0 == result_1
            XCTAssertTrue(isEqual)
            if !isEqual {
                print("points: \(testSet.map({ $0.xSegment }))")
                break
            }
            
            list.clear()
        }
    }
    
    func test_random_intersect_4() {
        let range: ClosedRange<Int32> = -10000...10000

        var list = ScanSplitList(count: 1)

        for _ in 0...10_000 {
            let testSet = self.test_set(range: range, count: 100)
            var result_0 = [Point]()
            var result_1 = [Point]()

            var tree = ScanSplitTree(range: testSet.range(), count: testSet.count)
            
            for v in testSet {
                if let res = list.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_0.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_0.append(res.cross.second)
                    }
                } else {
                    list.insert(segment: v)
                }
                
                if let res = tree.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_1.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_1.append(res.cross.second)
                    }
                } else {
                    tree.insert(segment: v)
                }
            }

            result_0.sort(by: { Point.xLineCompare(a: $0, b: $1) })
            result_1.sort(by: { Point.xLineCompare(a: $0, b: $1) })

            let isEqual = result_0 == result_1
            
            XCTAssertTrue(isEqual)
            if !isEqual {
                print("points: \(testSet.map({ $0.xSegment }))")
                break
            }
            
            list.clear()
            
        }
    }
    
    func test_random_intersect_5() {
        let range: ClosedRange<Int32> = -100...100

        var list = ScanSplitList(count: 1)
        
        for _ in 0...1_000 {
            let testSet = self.test_set(range: range, count: 10000)
            var result_0 = [Point]()
            var result_1 = [Point]()
            
            var tree = ScanSplitTree(range: testSet.range(), count: testSet.count)
            
            for v in testSet {
                if let res = list.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_0.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_0.append(res.cross.second)
                    }
                } else {
                    list.insert(segment: v)
                }
                
                if let res = tree.intersect(this: v.xSegment, scanPos: v.xSegment.a) {
                    result_1.append(res.cross.point)
                    if res.cross.type == .penetrate {
                        result_1.append(res.cross.second)
                    }
                } else {
                    tree.insert(segment: v)
                }
            }

            result_0.sort(by: { Point.xLineCompare(a: $0, b: $1) })
            result_1.sort(by: { Point.xLineCompare(a: $0, b: $1) })

            let isEqual = result_0 == result_1
            
            XCTAssertTrue(isEqual)
            if !isEqual {
                print("points: \(testSet.map({ $0.xSegment }))")
                break
            }
            
            list.clear()
        }
    }
    
    
    func test_set(range: ClosedRange<Int32>, count: Int) -> [VersionSegment] {
        var result = [VersionSegment]()
        result.reserveCapacity(count)
        for i in 0..<count {
            let x = Int32.random(in: range)
            let y = Int32.random(in: range)

            var s: Int32
            repeat {
                s = Int32.random(in: range)
            } while s == 0
            
            let a = Point(x, y)
            let b: Point
            switch Int.random(in: 0...2) {
            case 0:
                b = Point(x, y + s)
            case 1:
                b = Point(x + s, y)
            default:
                b = Point(x + s, y + s)
            }

            let xSegment: XSegment
            if Point.xLineCompare(a: a, b: b) {
                xSegment = XSegment(a: a, b: b)
            } else {
                xSegment = XSegment(a: b, b: a)
            }

            let version = VersionedIndex(version: UInt32(i), index: .empty)
            result.append(VersionSegment(vIndex: version, xSegment: xSegment))
        }
        
        result.sort(by: { Point.xLineCompare(a: $0.xSegment.a, b: $1.xSegment.a) })
        
        return result
    }
    
}

private extension Array where Element == VersionSegment {
    
    func range() -> LineRange {
        var min = Int32.max
        var max = Int32.min
        
        for s in self {
            min = Swift.min(min, s.xSegment.a.y)
            min = Swift.min(min, s.xSegment.b.y)
            
            max = Swift.max(max, s.xSegment.a.y)
            max = Swift.max(max, s.xSegment.b.y)
        }

        return LineRange(min: min, max: max)
    }
    
}


private extension Array where Element == XSegment {
    
    func range() -> LineRange {
        var min = Int32.max
        var max = Int32.min
        
        for s in self {
            min = Swift.min(min, s.a.y)
            min = Swift.min(min, s.b.y)
            
            max = Swift.max(max, s.a.y)
            max = Swift.max(max, s.b.y)
        }

        return LineRange(min: min, max: max)
    }
    
}
