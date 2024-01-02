//
//  LineSpaceTests.swift
//
//
//  Created by Nail Sharipov on 02.01.2024.
//

import XCTest
import iShape
import iFixFloat
@testable import iOverlay

final class LineSpaceTests: XCTestCase {
    
    func test_00() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.index(range: LineRange(min: 0, max: 31)), 0)
        XCTAssertEqual(indexer.index(range: LineRange(min: 1, max: 31)), 0)
        XCTAssertEqual(indexer.index(range: LineRange(min: 1, max: 30)), 0)
        XCTAssertEqual(indexer.index(range: LineRange(min: 0, max: 15)), 0)
        XCTAssertEqual(indexer.index(range: LineRange(min: 16, max: 31)), 0)
        XCTAssertEqual(indexer.index(range: LineRange(min: 10, max: 20)), 0)
        XCTAssertEqual(indexer.index(range: LineRange(min: 0, max: 7)), 1)
        XCTAssertEqual(indexer.index(range: LineRange(min: 8, max: 15)), 1)
        XCTAssertEqual(indexer.index(range: LineRange(min: 16, max: 23)), 2)
        XCTAssertEqual(indexer.index(range: LineRange(min: 24, max: 31)), 2)
        XCTAssertEqual(indexer.index(range: LineRange(min: 4, max: 11)), 1)
        XCTAssertEqual(indexer.index(range: LineRange(min: 12, max: 19)), 3)
        XCTAssertEqual(indexer.index(range: LineRange(min: 20, max: 27)), 2)
        XCTAssertEqual(indexer.index(range: LineRange(min: 10, max: 11)), 5)
    }

    func test_000() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.index(range: LineRange(min: 0, max: 31)), 0)
    }
    
    func test_001() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.index(range: LineRange(min: 0, max: 1)), 4)
        XCTAssertEqual(indexer.index(range: LineRange(min: 0, max: 0)), 4)
    }

    func test_01() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 0, max: 31)).sorted(), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
    
    func test_02() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 0, max: 15)).sorted(), [0, 1, 3, 4, 5, 8, 9])
    }
    
    func test_03() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 0, max: 7)).sorted(), [0, 1, 4, 8])
    }
    
    func test_04() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 0, max: 8)).sorted(), [0, 1, 3, 4, 5, 8])
    }
    
    func test_05() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 0, max: 3)).sorted(), [0, 1, 4])
    }
    
    func test_06() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 0, max: 4)).sorted(), [0, 1, 4, 8])
    }
    
    func test_07() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 29, max: 31)).sorted(), [0, 2, 7])
    }
    
    func test_08() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 28, max: 31)).sorted(), [0, 2, 7])
    }
    
    func test_09() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 27, max: 31)).sorted(), [0, 2, 7, 10])
    }
    
    func test_10() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 26, max: 31)).sorted(), [0, 2, 7, 10])
    }
    
    func test_11() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 24, max: 31)).sorted(), [0, 2, 7, 10])
    }
    
    func test_12() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 23, max: 31)).sorted(), [0, 2, 3, 6, 7, 10])
    }
    
    func test_13() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 7, max: 28)).sorted(), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }
    
    func test_14() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 3, max: 29)).sorted(), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
    }

    func test_15() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 18, max: 26)).sorted(), [0, 2, 3, 6, 7, 9, 10])
    }

    func test_16() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 22, max: 29)).sorted(), [0, 2, 3, 6, 7, 10])
    }

    func test_17() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.heapIndices(range: LineRange(min: 19, max: 23)).sorted(), [0, 2, 3, 6, 9, 10])
    }
    
    func test_18() throws {
        let indexer = LineIndexer(level: 2, range: LineRange(min: 0, max: 31))
        XCTAssertEqual(indexer.index(range: LineRange(min: -35, max: 17)), 0)
    }
    
    
    func test_20() throws {
        var scanList = LineSpace<Int>(level: 2, range: LineRange(min: 0, max: 31))
        scanList.insert(segment: LineSegment(id: 0, range: LineRange(min: 23, max: 27)))
        scanList.insert(segment: LineSegment(id: 1, range: LineRange(min: 27, max: 29)))

        let ids = scanList.allIdsInRange(range: LineRange(min: 21, max: 25)).sorted()
        
        XCTAssertEqual(ids, [0])
    }
    
    func test_21() throws {
        var scanList = LineSpace<Int>(level: 2, range: LineRange(min: 0, max: 31))
        scanList.insert(segment: LineSegment(id: 0, range: LineRange(min: 3, max: 18)))
        scanList.insert(segment: LineSegment(id: 1, range: LineRange(min: 3, max: 20)))

        let ids = scanList.allIdsInRange(range: LineRange(min: 3, max: 18)).sorted()
        
        XCTAssertEqual(ids, [0, 1])
    }
    
    func test_22() throws {
        var scanList = LineSpace<Int>(level: 2, range: LineRange(min: 0, max: 31))
        scanList.insert(segment: LineSegment(id: 0, range: LineRange(min: 0, max: 14)))
        scanList.insert(segment: LineSegment(id: 1, range: LineRange(min: 21, max: 25)))

        let ids = scanList.allIdsInRange(range: LineRange(min: 17, max: 20)).sorted()
        
        XCTAssertEqual(ids, [])
    }
    
    func test_23() throws {
        var scanList = LineSpace<Int>(level: 2, range: LineRange(min: 0, max: 31))
        scanList.insert(segment: LineSegment(id: 0, range: LineRange(min: 11, max: 15)))
        scanList.insert(segment: LineSegment(id: 1, range: LineRange(min: 16, max: 27)))

        let ids = scanList.allIdsInRange(range: LineRange(min: 5, max: 19)).sorted()
        
        XCTAssertEqual(ids, [0, 1])
    }
    
    func test_24() throws {
        var scanList = LineSpace<Int>(level: 2, range: LineRange(min: 21, max: 26))
        scanList.insert(segment: LineSegment(id: 0, range: LineRange(min: 21, max: 26)))
        scanList.insert(segment: LineSegment(id: 1, range: LineRange(min: 25, max: 26)))

        let ids = scanList.allIdsInRange(range: LineRange(min: 21, max: 26)).sorted()
        
        XCTAssertEqual(ids, [0, 1])
    }
    
    func test_25() throws {
        var scanList = LineSpace<Int>(level: 2, range: LineRange(min: 4, max: 19))
        scanList.insert(segment: LineSegment(id: 0, range: LineRange(min: 4, max: 18)))
        scanList.insert(segment: LineSegment(id: 1, range: LineRange(min: 10, max: 19)))

        let ids = scanList.allIdsInRange(range: LineRange(min: 13, max: 19)).sorted()
        
        XCTAssertEqual(ids, [0, 1])
    }
    
    func test_26() throws {
        var scanList = LineSpace<Int>(level: 2, range: LineRange(min: 0, max: 151))
        scanList.insert(segment: LineSegment(id: 0, range: LineRange(min: 83, max: 151)))
        scanList.insert(segment: LineSegment(id: 1, range: LineRange(min: 0, max: 49)))

        let ids = scanList.allIdsInRange(range: LineRange(min: 49, max: 123)).sorted()
        
        XCTAssertEqual(ids, [0, 1])
    }
    
    func test_27() throws {
        var scanList = LineSpace<Int>(level: 2, range: LineRange(min: -65, max: 86))
        scanList.insert(segment: LineSegment(id: 0, range: LineRange(min: 18, max: 86)))
        scanList.insert(segment: LineSegment(id: 1, range: LineRange(min:-65, max:-16)))

        let ids = scanList.allIdsInRange(range: LineRange(min: -16, max: 58)).sorted()
        
        XCTAssertEqual(ids, [0, 1])
    }
    
    func test_28() throws {
        var scanList = LineSpace<Int>(level: 2, range: LineRange(min: -54, max: 17))
        scanList.insert(segment: LineSegment(id: 0, range: LineRange(min: -35, max:  17)))
        scanList.insert(segment: LineSegment(id: 1, range: LineRange(min: -54, max: -29)))

        let ids = scanList.allIdsInRange(range: LineRange(min: -39, max: -30)).sorted()
        
        XCTAssertEqual(ids, [0, 1])
    }
    
    func test_single_random() throws {
        let min: Int32 = -10
        let max: Int32 = 10

        let segments = Self.randomSegemnts(min: min, max: max, count: 2)

        let realMin = segments.min(by: { $0.range.min < $1.range.min })?.range.min ?? 0
        let realMax = segments.max(by: { $0.range.max < $1.range.max })?.range.max ?? 0

        for level in 2..<20 {
            var scanList = LineSpace<Int>(level: level, range: LineRange(min: realMin, max: realMax))
            for segment in segments {
                scanList.insert(segment: segment)
            }

            for _ in 0..<10_000 {
                let range = Self.randomRange(min: realMin, max: realMax)
                
                let idsA = segments.filter({ $0.range.isOverlap(range) }).map({ $0.id }).sorted()
                let idsB = scanList.allIdsInRange(range: range).sorted()
                
                if idsA != idsB {
                    print("level: \(level)")
                    print("segments: \(segments)")
                    print("range: \(range)")
                    
                    XCTAssertEqual(idsA, idsB)
                    
                    return
                }
            }
        }
    }
    
    func test_random() throws {
        for _ in 0..<100 {
            let min = -Int32.random(in: 10..<100)
            let max = Int32.random(in: 10..<100)

            let segments = Self.randomSegemnts(min: min, max: max, count: 2)

            let realMin = segments.min(by: { $0.range.min < $1.range.min })?.range.min ?? 0
            let realMax = segments.max(by: { $0.range.max < $1.range.max })?.range.max ?? 0

            for level in 2..<20 {
                var scanList = LineSpace<Int>(level: level, range: LineRange(min: realMin, max: realMax))
                for segment in segments {
                    scanList.insert(segment: segment)
                }

                for _ in 0..<1_00 {
                    let range = Self.randomRange(min: realMin, max: realMax)
                    
                    let idsA = segments.filter({ $0.range.isOverlap(range) }).map({ $0.id }).sorted()
                    let idsB = scanList.allIdsInRange(range: range).sorted()
                    
                    if idsA != idsB {
                        print("min: \(min) max: \(max)")
                        print("level: \(level)")
                        print("segments: \(segments)")
                        print("range: \(range)")
                        
                        XCTAssertEqual(idsA, idsB)
                        
                        return
                    }
                }
            }
        }
    }

    private static func randomSegemnts(min: Int32, max: Int32, count: Int) -> [LineSegment<Int>] {
        var result = [LineSegment<Int>]()
        result.reserveCapacity(count)
        for id in 0..<count {
            let range = Self.randomRange(min: min, max: max)
            result.append(LineSegment<Int>(id: id, range: range))
        }
        
        return result
    }

    private static func randomRange(min: Int32, max: Int32) -> LineRange {
        let a = Int32.random(in: min..<max)
        let b = Int32.random(in: min..<max)
        if a == b {
            return LineRange(min: a, max: b + 1)
        } else if a < b {
            return LineRange(min: a, max: b)
        } else {
            return LineRange(min: b, max: a)
        }

    }
    
}

private extension LineIndexer {

    // Test purpose only, must be same logic as in iterateAllInRange
    func heapIndices(range: LineRange) -> [Int] {
        var result = [Int]()
        self.fill(range: range, buffer: &result)
        return result
    }
}

private extension LineSpace {

    mutating func allIdsInRange(range: LineRange) -> [Id] {
        var result = [Id]()
        self.fillIdsInRange(range: range, ids: &result)
        
        return result
    }
    
}
