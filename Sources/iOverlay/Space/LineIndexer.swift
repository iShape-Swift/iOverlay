//
//  LineIndexer.swift
//
//
//  Created by Nail Sharipov on 02.01.2024.
//

public struct LineIndexer {

    public let scale: Int
    public let size: Int
    public let range: LineRange
    public let maxLevel: Int
    private let offset: Int

    public init(level n: Int, range: LineRange) {
        let xMin = Int(range.min)
        let xMax = Int(range.max)
        let dif = xMax - xMin

        let dLog = dif.logTwo
        if dif <= 2 {
            maxLevel = 0
        } else {
            maxLevel = min(10, min(n, dLog - 1))
        }
        offset = -xMin
        scale = dLog - maxLevel
        self.range = range
        assert(scale >= 0)

        size = Self.spaceCount(level: maxLevel)
    }

    public func unsafe_index(range: LineRange) -> Int {
        guard maxLevel > 0 else {
            return 0
        }
        
        assert(range.min >= self.range.min)
        assert(range.max <= self.range.max)
        
        // scale to indexer coordinate system
        var iMin = Int(range.min) + offset
        var iMax = Int(range.max) + offset
        
        let dif = (iMax - iMin) >> (scale - 1)
        let dLog = dif.logTwo
        
        let level = dLog < maxLevel ? maxLevel - dLog : 0

        let s = scale + dLog
        
        iMin = iMin >> s
        iMax = iMax >> s

        let iDif = iMax - iMin
        let index = Self.customSpaceCount(mainLevel: level + iDif, secondLevel: level) + iMin
        
        return index
    }
    
    public func index(range: LineRange) -> Int {
        let clampRange = LineRange(
            min: max(self.range.min, range.min),
            max: min(self.range.max, range.max)
        )
        
        return self.unsafe_index(range: clampRange)
    }

    public func fill(range: LineRange, buffer: inout [Int]) {
        let clamp = range.clamp(range: self.range)
        self.fillUnsafe(range: clamp, buffer: &buffer)
    }
    
    public func fillUnsafe(range: LineRange, buffer: inout [Int]) {
        guard maxLevel > 0 else {
            buffer.append(0)
            return
        }
        
        let x0 = Int(range.min) + offset
        let x1 = Int(range.max) + offset
        
        var xLeft = x0 >> scale
        var xRight = x1 >> scale
        
        for n in 1...maxLevel {
            
            let level = maxLevel - n
            let indexOffset = Self.spaceCount(level: level)
            
            for x in xLeft...xRight {
                let index = indexOffset + x
                assert(index > 0)
                buffer.append(index)
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
            if xLeft > 0 {
                xLeft = (xLeft - 1) >> 1
            }

            if xRight > 0 {
                xRight = (xRight - 1) >> 1
            }

            let indexOffset = Self.middleSpaceCount(level: level)
            
            xLeft = Swift.min(xLeft, xMax)
            xRight = Swift.min(xRight, xMax)
            
            for x in xLeft...xRight {
                let index = indexOffset + x
                assert(index > 0)
                buffer.append(index)
            }
        }

        buffer.append(0)
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
