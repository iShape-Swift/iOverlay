//
//  TreeIndexSearchTests.swift
//
//
//  Created by Nail Sharipov on 29.04.2024.
//

import XCTest
@testable import iOverlay

final class TreeIndexSearchTests: XCTestCase {
    
    
    func test_00() throws {
        XCTAssertEqual(1, TestFindIndex.findIndex(array: [0], target: 1))
        XCTAssertEqual(0, TestFindIndex.findIndex(array: [0], target: 0))
        XCTAssertEqual(0, TestFindIndex.findIndex(array: [0], target: -1))
    }
    
    func test_sequence() throws {
        for i in 1..<Int32(1000) {
            let array = Array(0..<i)
            for j in -1...i {
                let goal = max(0, Int(j))
                XCTAssertEqual(goal, TestFindIndex.findIndex(array: array, target: j))
            }
        }
    }
    
}
