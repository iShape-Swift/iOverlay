//
//  TreeTests.swift
//
//
//  Created by Nail Sharipov on 25.02.2024.
//

import XCTest
import iFixFloat
@testable import iOverlay

final class TreeTests: XCTestCase {
    
    func test_00() throws {
        var tree = RedBlackTree(empty: TreeSegment(index: .max, xSegment: .init(a: .zero, b: .zero)) )
        
        tree.insert(value: TreeSegment(index: 0, xSegment: .init(a: FixVec(0, 0), b: FixVec(1000, 1000))))
        tree.insert(value: TreeSegment(index: 1, xSegment: .init(a: FixVec(500, -250), b: FixVec(1500, -1250))))
        tree.insert(value: TreeSegment(index: 2, xSegment: .init(a: FixVec(250, -750), b: FixVec(750, -750))))
        
        let root = tree[tree.root]
        
        XCTAssertEqual(root.value.index, 1)
        XCTAssertEqual(tree[root.left].value.index, 2)
        XCTAssertEqual(tree[root.right].value.index, 0)
    }

    func test_01() throws {
        var tree = RedBlackTree(empty: TreeSegment(index: .max, xSegment: .init(a: .zero, b: .zero)) )
        
        tree.insert(value: TreeSegment(index: 0, xSegment: .init(a: FixVec(0,     0), b: FixVec(1000,     0))))
        tree.insert(value: TreeSegment(index: 1, xSegment: .init(a: FixVec(0,  1000), b: FixVec(1000,  1000))))
        tree.insert(value: TreeSegment(index: 2, xSegment: .init(a: FixVec(0, -1000), b: FixVec(1000, -1000))))
        
        let root = tree[tree.root]
        
        XCTAssertEqual(root.value.index, 0)
        XCTAssertEqual(tree[root.left].value.index, 2)
        XCTAssertEqual(tree[root.right].value.index, 1)
    }
    
    func test_03() throws {
        var tree = RedBlackTree(empty: TreeSegment(index: .max, xSegment: .init(a: .zero, b: .zero)) )
        
        tree.insert(value: TreeSegment(index: 0, xSegment: .init(a: FixVec(0, 0), b: FixVec(1000, -1000))))
        tree.insert(value: TreeSegment(index: 1, xSegment: .init(a: FixVec(0, 0), b: FixVec(1000,     0))))
        tree.insert(value: TreeSegment(index: 2, xSegment: .init(a: FixVec(0, 0), b: FixVec(1000,  1000))))
        
        let root = tree[tree.root]
        
        XCTAssertEqual(root.value.index, 1)
        XCTAssertEqual(tree[root.left].value.index, 0)
        XCTAssertEqual(tree[root.right].value.index, 2)
    }
    
    
}
