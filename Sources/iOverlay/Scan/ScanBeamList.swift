//
//  ScanBeamList.swift
//
//
//  Created by Nail Sharipov on 03.12.2023.
//

public struct ScanBeamList {

    private let scale: Int
    private let yOffset: Int
    private let maxLevel: Int
    private let iOffset: [Int]
    private var heap: [[VSegment]]
    
    init(level: Int, minY: Int, maxY: Int) {
        let height = maxY - minY

        let htLog = height.logTwo
        maxLevel = min(10, min(level, htLog))
        let spaceHeight = 1 << htLog
        yOffset = (spaceHeight - height) / 2
        scale = htLog - maxLevel
        
        var iOffsetByLevel = Self.calculateIndexOffsetByLevel(maxLevel + 1)
        let heapSize = iOffsetByLevel.removeLast()
        iOffset = iOffsetByLevel
        heap = [[VSegment]](repeating: [], count: heapSize)
    }
    
    static private func calculateIndexOffsetByLevel(_ n: Int) -> [Int] {
        // calculate index offset for every level
        var s = 0
        var offset = [Int]()
        offset.reserveCapacity(n)
        for i in 0..<n {
            s += (1 << i) * (n - i)
            offset.append(s)
        }
        
        return offset
    }
    
    mutating func insert(segment: VSegment) {
        let hy = Int(segment.max - segment.min)
        let min_y = Int(segment.min)
        let max_y = Int(segment.max)
        
        let height = hy >> scale
        let ht = height.logTwo // height level
        
        let s = scale + ht
        
        let iMin = (min_y + yOffset) >> s
        let iMax = (max_y + yOffset) >> s

        let j = iMax - iMin // 0 or 1, 1 if in the middle
        
        let rowIndex = (iMin >> j).logTwo
        
        let level = maxLevel - ht - j
        
        let i = self.heapIndex(level: level, index: rowIndex, height: ht)

        self.heap[i].append(segment)
    }
    
    private func heapIndex(level: Int, index: Int, height: Int) -> Int {
        let m = maxLevel - level
        let h = maxLevel - height
        let i = iOffset[level - 1] + m * index + h
        return i
    }

    // return all heap indices which can contain segments which possibly can overlap this range minY...maxY
    func heapIndices(minY: Int, maxY: Int) -> [Int] {
        var indices = [Int]()
        
        let minHt = (minY + yOffset) >> scale
        let maxHt = (maxY + yOffset) >> scale
        let minLevel = minHt.logTwo
        let maxLevel = maxHt.logTwo

        // Iterate through the levels that could be affected
        for level in minLevel...maxLevel {
            let startHeightIndex = max(minHt >> (level - minLevel), 0)
            let endHeightIndex = min(maxHt >> (level - minLevel), (1 << (maxLevel - level)) - 1)
            
            for heightIndex in startHeightIndex...endHeightIndex {
                // Calculate the heap index for this level and heightIndex
                let heapIndex = self.heapIndex(level: level, index: heightIndex, height: level)
                indices.append(heapIndex)
            }
        }

        return indices
    }
    
}


private extension Int {
    var logTwo: Int {
        guard self > 0 else {
            return 0
        }
        let n = abs(self).leadingZeroBitCount
        return Int.bitWidth - n
    }
}
