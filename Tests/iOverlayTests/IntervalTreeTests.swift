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
        let nodes = ScanTree.testInitNodes(range: LineRange(min: 0, max: 128), power: 4)
        
        XCTAssertEqual(nodes.count, 31)
    }
    
    func test_01() throws {
        let nodes = ScanTree.testInitNodes(range: LineRange(min: 0, max: 128), power: 5)
        XCTAssertEqual(nodes.count, 63)
    }
    
    func test_02() throws {
        var tree = ScanTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: FixVec(0, 1), b: FixVec(0, 127))
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
        var tree = ScanTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: FixVec(0, 16), b: FixVec(0, 112))
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
        var tree = ScanTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: FixVec(0, 17), b: FixVec(0, 111))
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
        var tree = ScanTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: FixVec(0, 32), b: FixVec(0, 96))
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
        var tree = ScanTree(range: LineRange(min: 0, max: 128), power: 3)
        let xSeg = XSegment(a: FixVec(0, 33), b: FixVec(0, 95))
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
}
