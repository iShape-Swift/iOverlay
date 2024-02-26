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
    
    
    func test_10() throws {
        var tree = RedBlackTree(empty: 0)
        for value in [-10, -7, 0, 5, 7, 10, 20] {
            tree.insert(value: value)
        }
        
        XCTAssertEqual(tree.lessAndNearest(value: -10), nil)
        XCTAssertEqual(tree.lessAndNearest(value: -9), -10)
        XCTAssertEqual(tree.lessAndNearest(value: -7), -10)
        XCTAssertEqual(tree.lessAndNearest(value: -6), -7)
        XCTAssertEqual(tree.lessAndNearest(value:  0), -7)
        XCTAssertEqual(tree.lessAndNearest(value:  1),  0)
        XCTAssertEqual(tree.lessAndNearest(value:  5),  0)
        XCTAssertEqual(tree.lessAndNearest(value:  6),  5)
        XCTAssertEqual(tree.lessAndNearest(value:  7),  5)
        XCTAssertEqual(tree.lessAndNearest(value:  8),  7)
        XCTAssertEqual(tree.lessAndNearest(value: 10),  7)
        XCTAssertEqual(tree.lessAndNearest(value: 11), 10)
        XCTAssertEqual(tree.lessAndNearest(value: 20), 10)
        XCTAssertEqual(tree.lessAndNearest(value: 21), 20)
    }
    

    func test_11() throws {
        var tree = RedBlackTree(empty: 0)
        for value in 0...100 {
            tree.insert(value: value)
        }
        
        XCTAssertEqual(tree.lessAndNearest(value: 0), nil)
        
        for value in 1...100 {
            XCTAssertEqual(tree.lessAndNearest(value: value), value - 1)
        }
    }
    
    func test_12() throws {
        var tree = RedBlackTree(empty: TreeSegment(index: .max, xSegment: .init(a: .zero, b: .zero)) )
        
        tree.insert(value: TreeSegment(index: 0, xSegment: .init(a: FixVec(0, 0), b: FixVec(200,  200))))
        tree.insert(value: TreeSegment(index: 1, xSegment: .init(a: FixVec(0, 0), b: FixVec(200,    0))))
        tree.insert(value: TreeSegment(index: 2, xSegment: .init(a: FixVec(0, 0), b: FixVec(200, -200))))

        XCTAssertEqual(tree.underAndNearest(point: Point(50,  100)), 0)
        XCTAssertEqual(tree.underAndNearest(point: Point(50, -100)), nil)
        
        XCTAssertEqual(tree.underAndNearest(point: Point(100,  100)),   1)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,    0)),   2)
        XCTAssertEqual(tree.underAndNearest(point: Point(100, -100)), nil)
    }
    
    func test_13() throws {
        var tree = RedBlackTree(empty: TreeSegment(index: .max, xSegment: .init(a: .zero, b: .zero)) )
        
        tree.insert(value: TreeSegment(index: 0, xSegment: .init(a: FixVec(0,  400), b: FixVec(200,  400))))
        tree.insert(value: TreeSegment(index: 1, xSegment: .init(a: FixVec(0,  400), b: FixVec(200,  200))))
        tree.insert(value: TreeSegment(index: 2, xSegment: .init(a: FixVec(0,  200), b: FixVec(200,  200))))
        tree.insert(value: TreeSegment(index: 3, xSegment: .init(a: FixVec(0,    0), b: FixVec(200,  200))))
        tree.insert(value: TreeSegment(index: 4, xSegment: .init(a: FixVec(0,    0), b: FixVec(200,    0))))
        tree.insert(value: TreeSegment(index: 5, xSegment: .init(a: FixVec(0,    0), b: FixVec(200, -200))))
        tree.insert(value: TreeSegment(index: 6, xSegment: .init(a: FixVec(0, -200), b: FixVec(200, -200))))
        tree.insert(value: TreeSegment(index: 7, xSegment: .init(a: FixVec(0, -400), b: FixVec(200, -200))))
        tree.insert(value: TreeSegment(index: 8, xSegment: .init(a: FixVec(0, -400), b: FixVec(200, -400))))

        XCTAssertEqual(tree.underAndNearest(point: Point(100,  450)), 0)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,  400)), 1)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,  350)), 1)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,  300)), 2)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,  250)), 2)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,  200)), 3)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,  150)), 3)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,  100)), 4)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,   50)), 4)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,    0)), 5)
        XCTAssertEqual(tree.underAndNearest(point: Point(100,  -50)), 5)
        XCTAssertEqual(tree.underAndNearest(point: Point(100, -100)), 6)
        XCTAssertEqual(tree.underAndNearest(point: Point(100, -150)), 6)
        XCTAssertEqual(tree.underAndNearest(point: Point(100, -200)), 7)
        XCTAssertEqual(tree.underAndNearest(point: Point(100, -250)), 7)
        XCTAssertEqual(tree.underAndNearest(point: Point(100, -300)), 8)
        XCTAssertEqual(tree.underAndNearest(point: Point(100, -350)), 8)
        XCTAssertEqual(tree.underAndNearest(point: Point(100, -400)), nil)
        XCTAssertEqual(tree.underAndNearest(point: Point(100, -450)), nil)
    }
}

extension RedBlackTree where T == Int {
 
    func lessAndNearest(value: Int) -> Int? {
        var index = root
        var result: UInt32 = .empty
        while index != .empty {
            let node = self[index]
            if value <= node.value {
                index = node.left
            } else {
                result = index
                index = node.right
            }
        }
        
        if result == .empty {
            return nil
        } else {
            return self[result].value
        }
    }
}

extension RedBlackTree where T == TreeSegment {
 
    func underAndNearest(point: Point) -> Int? {
        var index = root
        var result: UInt32 = .empty
        while index != .empty {
            let node = self[index]
            if node.value.xSegment.isUnder(point: point) {
                result = index
                index = node.right
            } else {
                index = node.left
            }
        }
        
        if result == .empty {
            return nil
        } else {
            return self[result].value.index
        }
    }
    
    
    
}
