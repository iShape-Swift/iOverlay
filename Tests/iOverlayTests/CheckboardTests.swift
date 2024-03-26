//
//  CheckboardTests.swift
//
//
//  Created by Nail Sharipov on 26.03.2024.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class CheckboardTests: XCTestCase {
    
    func test_0() throws {
        XCTAssertEqual(1, test(n: 1, overlayRule: .xor))
    }
    
    func test_1() throws {
        XCTAssertEqual(5, test(n: 2, overlayRule: .xor))
    }
    
    func test_2() throws {
        XCTAssertEqual(13, test(n: 3, overlayRule: .xor))
    }

    func test_12() throws {
        let s = 12 * 12 + 11 * 11
        XCTAssertEqual(s, test(n: 12, overlayRule: .xor))
    }
    
    func test_n() throws {
        for i in 1..<20 {
            let s = i * i + (i - 1) * (i - 1)
            XCTAssertEqual(s, test(n: i, overlayRule: .xor))
        }
    }
    
    private func test(n: Int, overlayRule: OverlayRule) -> Int {
        let subjPaths = self.manySuares(
            start: .zero,
            size: 20,
            offset: 30,
            n: n
        )
        
        let clipPaths = self.manySuares(
            start: FixVec(15, 15),
            size: 20,
            offset: 30,
            n: n - 1
        )
       
        var overlay = Overlay()
        overlay.add(paths: subjPaths, type: .subject)
        overlay.add(paths: clipPaths, type: .clip)
        
        let graph = overlay.buildGraph(fillRule: .nonZero)
        
        let result = graph.extractShapes(overlayRule: overlayRule, minArea: 0)
        
        return result.count
    }
     
     private func manySuares(start: FixVec, size a: FixFloat, offset: FixFloat, n: Int) -> [FixPath] {
         var result = [FixPath]()
         result.reserveCapacity(n * n)
         var y = start.y
         for _ in 0..<n {
             var x = start.x
             for _ in 0..<n {
                 let path: FixPath = [
                     .init(x, y),
                     .init(x, y + a),
                     .init(x + a, y + a),
                     .init(x + a, y)
                 ]
                 result.append(path)
                 x += offset
             }
             y += offset
         }
         
         return result
     }
}
