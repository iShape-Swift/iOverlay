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

enum IterCommand<Id> {
    case next
    case removeAndNext
    case stop
    case addAndStop(LineSegment<Id>)
}

struct LineSpace<Id> {

    typealias NextEdge = (Id) -> IterCommand<Id>
    typealias Iteration = (Int) -> ()

    private let scale: Int
    private let offset: Int
    private let maxLevel: Int
    private var heap: [[LineSegment<Id>]]
    private var iterationBuffer: [Int]

    init(level n: Int, range: LineRange) {
        let xMin = Int(range.min)
        let xMax = Int(range.max)
        let dif = xMax - xMin

        let dLog = dif.logTwo
        maxLevel = min(10, min(n, dLog - 1))
        offset = -xMin
        scale = dLog - maxLevel
        assert(scale > 0)

        let size = Self.spaceCount(level: n)
        heap = [[LineSegment]](repeating: [], count: size)
        
        iterationBuffer = []
        iterationBuffer.reserveCapacity(size)
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
        
        let dif = (iMax - iMin) >> scale
        let dLog = dif.logTwo + 1
        
        let level = max(0, maxLevel - dLog)
        let s = scale + dLog
        
        iMin = iMin >> s
        iMax = iMax >> s

        let iDif = iMax - iMin
        let heapIndex = Self.customSpaceCount(mainLevel: level + iDif, secondLevel: level) + iMin
        
        return heapIndex
    }
    
//#if DEBUG
    // Test purpose only, must be same logic as in iterateAllInRange
    func heapIndices(range: LineRange) -> [Int] {
        var result = [Int]()
        self.fill(range: range, heapIndices: &result)
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
    
//#endif

    private func fill(range: LineRange, heapIndices: inout[Int]) {

        let x0 = Int(range.min) + offset
        let x1 = Int(range.max) + offset
        
        var xLeft = x0 >> scale
        var xRight = x1 >> scale
        
        for n in 1...maxLevel {
            
            let level = maxLevel - n
            let indexOffset = Self.spaceCount(level: level)
            
            for x in xLeft...xRight {
                heapIndices.append(indexOffset + x)
            }

            xLeft = xLeft >> 1
            xRight = xRight >> 1
        }
        
        
        var s = scale - 2
        for n in 1...maxLevel {
            let level = maxLevel - n
            var xMax = (level + 2).powerOfTwo - 1
            
            s += 1
            
            var xLeft = x0 >> s
            var xRight = x1 >> s

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
                heapIndices.append(indexOffset + x)
            }
        }

        heapIndices.append(0)
    }

    mutating func iterateSegmentsInRange(range: LineRange, callback: NextEdge) -> Bool {
        iterationBuffer.removeAll(keepingCapacity: true)
        self.fill(range: range, heapIndices: &iterationBuffer)
        
        for index in iterationBuffer where !heap[index].isEmpty {
            if self.iterate(index: index, range: range, callback: callback) {
                return false
            }
        }
        
        return true
    }
    
    private mutating func iterate(index: Int, range: LineRange, callback: NextEdge) -> Bool {
        var list = heap[index]

        var isModified = false
        var isBreak = false
        var i = 0
        loop:
        while i < list.count {
            let segment = list[i]
            if range.isOverlap(segment.range) {
                let command = callback(segment.id)
                
                switch command {
                case .next:
                    break
                case .removeAndNext:
                    if i + 1 < list.count {
                        list[i] = list.removeLast()
                    } else {
                        list.removeLast()
                    }
                    
                    isModified = true
                    continue
                case .stop:
                    isBreak = true
                    break loop
                case .addAndStop(let segment):
                    self.insert(segment: segment)
                    isBreak = true
                    break loop
                }
            }
            i += 1
        }
        
        if isModified {
            heap[index] = list
        }
        
        return isBreak
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
