//
//  LineSpace.swift
//
//
//  Created by Nail Sharipov on 06.12.2023.
//

struct LineSegment<Id> {
    let id: Id
    let range: LineRange
}

struct LineContainer<Id> {
    let id: Id
    let index: DualIndex
}

struct LineSpace<Id> {

    let scale: Int
    private let maxLevel: Int
    private let offset: Int
    private var heap: [[LineSegment<Id>]]
    private var heapBuffer: [Int] = []
    private var searchBuffer: [LineContainer<Id>] = []

    init(level n: Int, range: LineRange) {
        let xMin = Int(range.min)
        let xMax = Int(range.max)
        let dif = xMax - xMin

        let dLog = dif.logTwo
        maxLevel = min(10, min(n, dLog - 1))
        offset = -xMin
        scale = dLog - maxLevel
        assert(scale > 0)

        let size = Self.spaceCount(level: maxLevel)
        heap = [[LineSegment]](repeating: [], count: size)
    }
    
    mutating func insert(segment: LineSegment<Id>) {
        let index = self.heapIndex(range: segment.range)
        heap[index].append(segment)
    }
    
    mutating func clear() {
        for i in 0..<heap.count {
            heap[i].removeAll(keepingCapacity: true)
        }
    }

    func heapIndex(range: LineRange) -> Int {
        // scale to heap coordinate system
        var iMin = Int(range.min) + offset
        var iMax = Int(range.max) + offset
        
        let dif = (iMax - iMin) >> (scale - 1)
        let dLog = dif.logTwo
        
        let level = max(0, maxLevel - dLog)
        let s = scale + dLog
        
        iMin = iMin >> s
        iMax = iMax >> s

        let iDif = iMax - iMin
        let heapIndex = Self.customSpaceCount(mainLevel: level + iDif, secondLevel: level) + iMin
        
        return heapIndex
    }
    
    // Test purpose only, must be same logic as in iterateAllInRange
    func heapIndices(range: LineRange) -> [Int] {
        var result = [Int]()
        self.fillHeap(range: range, buffer: &result)
        return result
    }
    
    func allIdsInRange(range: LineRange) -> [Id] {
        var result = [Id]()
        
        let heapIndices = self.heapIndices(range: range)
        
        for index in heapIndices {
            let list = heap[index]
            for segm in list where segm.range.isOverlap(range) {
                result.append(segm.id)
            }
        }
        
        return result
    }

    private func fillHeap(range: LineRange, buffer: inout [Int]) {
        let x0 = Int(range.min) + offset
        let x1 = Int(range.max) + offset
        
        var xLeft = x0 >> scale
        var xRight = x1 >> scale
        
        for n in 1...maxLevel {
            
            let level = maxLevel - n
            let indexOffset = Self.spaceCount(level: level)
            
            for x in xLeft...xRight {
                let index = indexOffset + x
                if !heap[index].isEmpty {
                    buffer.append(index)
                }
            }

            xLeft = xLeft >> 1
            xRight = xRight >> 1
        }
        
        
        var s = scale - 1
        for n in 1...maxLevel {
            let level = maxLevel - n
            var xMax = (level + 2).powerOfTwo - 1

            var xLeft = x0 >> s
            var xRight = x1 >> s

            s += 1

            guard xRight > 0 && xLeft < xMax else {
                break
            }

            xMax = (level + 1).powerOfTwo - 2
            xLeft = max(0, xLeft - 1) >> 1
            xRight = max(0, xRight - 1) >> 1

            let indexOffset = Self.middleSpaceCount(level: level)
            
            xLeft = Swift.min(xLeft, xMax)
            xRight = Swift.min(xRight, xMax)
            
            for x in xLeft...xRight {
                let index = indexOffset + x
                if !heap[index].isEmpty {
                    buffer.append(index)
                }
            }
        }

        if !heap[0].isEmpty {
            buffer.append(0)
        }
    }
    
    mutating func allInRange(range: LineRange) -> [LineContainer<Id>] {
        heapBuffer.removeAll(keepingCapacity: true)
        self.fillHeap(range: range, buffer: &heapBuffer)

        searchBuffer.removeAll(keepingCapacity: true)
        for heapIndex in heapBuffer {
            let segments = heap[heapIndex]

            for segmentIndex in 0..<segments.count {
                if range.isOverlap(segments[segmentIndex].range) {
                    searchBuffer.append(.init(id: segments[segmentIndex].id, index: .init(major: UInt32(heapIndex), minor: UInt32(segmentIndex))))
                }
            }
        }

        return searchBuffer
    }
    
    mutating func remove(index: DualIndex) {
        let heapIndex = Int(index.major)
        let listIndex = Int(index.minor)

        if listIndex + 1 < heap[heapIndex].count {
            heap[heapIndex][listIndex] = heap[heapIndex].removeLast()
        } else {
            heap[heapIndex].removeLast()
        }
    }
    
    private static func spaceCount(level: Int) -> Int {
        (level + 2).powerOfTwo - level - 3
    }
    
    private static func middleSpaceCount(level: Int) -> Int {
        (level + 2).powerOfTwo + (level + 1).powerOfTwo - level - 3
    }
    
    private static func customSpaceCount(mainLevel: Int, secondLevel: Int) -> Int {
        let main = mainLevel.powerOfTwo - 1
        let second = secondLevel.powerOfTwo - secondLevel - 1
        return main + second
    }
}

extension Int {
    
    var powerOfTwo: Int {
        1 << self
    }
    
    var logTwo: Int {
        guard self > 0 else {
            return 0
        }
        let n = abs(self).leadingZeroBitCount
        return Int.bitWidth - n
    }
}
