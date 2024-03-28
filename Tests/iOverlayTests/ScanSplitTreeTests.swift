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
        let a0 = Point(0, -6)
        let b0 = Point(8,  0)
        let a1 = Point(0,  3)
        let b1 = Point(8,  8)
        let vs = VersionSegment(vIndex: version, xSegment: XSegment(a: a0, b: b0))
        let xs = XSegment(a: a1, b: b1)
        
        tree.insert(segment: vs)
        let r1 = tree.intersectAndRemoveOther(this: xs)
        
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
        let range = testSet.range()
        var tree = ScanSplitTree(range: range, count: testSet.count)
        var i = 0
        for s in testSet {
            if let res = tree.intersectAndRemoveOther(this: s) {
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
            if let res = tree.intersectAndRemoveOther(this: s) {
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
            if let res = tree.intersectAndRemoveOther(this: s) {
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
        for _ in 0...100_000 {
            let a0 = Point(0, Int32.random(in: range))
            let b0 = Point(8, Int32.random(in: range))
            let a1 = Point(0, Int32.random(in: range))
            let b1 = Point(8, Int32.random(in: range))
            
            let vs = VersionSegment(vIndex: version, xSegment: XSegment(a: a0, b: b0))
            let xs = XSegment(a: a1, b: b1)
            list.insert(segment: vs)
            tree.insert(segment: vs)
            
            let r0 = list.intersectAndRemoveOther(this: xs)
            let r1 = tree.intersectAndRemoveOther(this: xs)

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
