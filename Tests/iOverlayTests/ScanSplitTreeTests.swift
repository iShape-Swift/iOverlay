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
