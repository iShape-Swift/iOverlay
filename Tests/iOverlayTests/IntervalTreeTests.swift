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
        let nodes = SegmentTree.testInitNodes(range: LineRange(min: 0, max: 128), power: 4)
        
        XCTAssertEqual(nodes.count, 31)
    }
    
    func test_01() throws {
        let nodes = SegmentTree.testInitNodes(range: LineRange(min: 0, max: 128), power: 5)
        XCTAssertEqual(nodes.count, 63)
    }
    
    func test_02() throws {
        var tree = SegmentTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 1), b: Point(0, 127))
        tree.insert(fragment: Fragment(index: 0, xSegment: xSeg))
        
        
        XCTAssertTrue(!tree.node(index: 0).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 1).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 2).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 4).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 5).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 6).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 8).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 9).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:10).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index:11).fragments.isEmpty)
        
        XCTAssertTrue(!tree.node(index:12).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:13).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index:14).fragments.isEmpty)
    }
    
    func test_03() throws {
        var tree = SegmentTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 16), b: Point(0, 112))
        tree.insert(fragment: Fragment(index: 0, xSegment: xSeg))
        
        
        XCTAssertTrue(tree.node(index: 0).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 1).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 2).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 4).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 5).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 6).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 8).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 9).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:10).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index:11).fragments.isEmpty)
        
        XCTAssertTrue(!tree.node(index:12).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:13).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:14).fragments.isEmpty)
    }
    
    func test_04() throws {
        var tree = SegmentTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 17), b: Point(0, 111))
        tree.insert(fragment: Fragment(index: 0, xSegment: xSeg))
        
        
        XCTAssertTrue(tree.node(index: 0).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 1).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 2).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 4).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 5).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 6).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 8).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 9).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:10).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index:11).fragments.isEmpty)
        
        XCTAssertTrue(!tree.node(index:12).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:13).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:14).fragments.isEmpty)
    }
    
    func test_05() throws {
        var tree = SegmentTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 32), b: Point(0, 96))
        tree.insert(fragment: Fragment(index: 0, xSegment: xSeg))
        
        
        XCTAssertTrue(tree.node(index: 0).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 1).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 2).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 4).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 5).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 6).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 8).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 9).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:10).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index:11).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index:12).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:13).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:14).fragments.isEmpty)
    }
    
    func test_06() throws {
        var tree = SegmentTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: Point(0, 33), b: Point(0, 95))
        tree.insert(fragment: Fragment(index: 0, xSegment: xSeg))
        
        XCTAssertTrue(tree.node(index: 0).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 1).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 2).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 3).fragments.isEmpty)
        
        XCTAssertTrue(!tree.node(index: 4).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 5).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index: 6).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index: 7).fragments.isEmpty)
        
        XCTAssertTrue(!tree.node(index: 8).fragments.isEmpty)
        XCTAssertTrue(tree.node(index: 9).fragments.isEmpty)
        XCTAssertTrue(!tree.node(index:10).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index:11).fragments.isEmpty)
        
        XCTAssertTrue(tree.node(index:12).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:13).fragments.isEmpty)
        XCTAssertTrue(tree.node(index:14).fragments.isEmpty)
    }
    
    func test_07() throws {
        var tree = SegmentTree(range: LineRange(min: -8, max: 9), power: 3)
        let a0 = Point(0, -6)
        let b0 = Point(8,  0)
        let a1 = Point(0,  3)
        let b1 = Point(8,  8)
        
        tree.insert(fragment: Fragment(index: 0, xSegment: XSegment(a: a0, b: b0)))
        
        var marks = [LineMark]()
        
        _ = tree.intersect(this: Fragment(index: 0, xSegment: XSegment(a: a1, b: b1)), marks: &marks)
        
        XCTAssertTrue(marks.isEmpty)
    }
    
    
    func test_08() throws {
        let s0 = XSegment(a: Point(-28, -28), b: Point(-20, 0))
        let s1 = XSegment(a: Point(-21, 1), b: Point(-15, -13))

        let range = LineRange(min: -28, max: 28)
        let layout = SpaceLayout(range: range, count: 16)
        var tree = SegmentTree(range: range, power: layout.power)
        tree.insert(fragment: Fragment(index: 0, xSegment: s0))

        var marks = [LineMark]()
        
        _ = tree.intersect(this: Fragment(index: 0, xSegment: s1), marks: &marks)
        
        let r1 = CrossSolver.cross(target: s0, other: s1)
        
        XCTAssertFalse(marks.isEmpty)
        XCTAssertNotNil(r1)
    }
    
}
