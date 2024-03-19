//
//  LineRange.swift
//
//
//  Created by Nail Sharipov on 06.12.2023.
//

public struct LineRange: Equatable {
    
    public let min: Int32
    public let max: Int32
    
    @inline(__always)
    public init(min: Int32, max: Int32) {
        self.min = min
        self.max = max
    }
}

public extension LineRange {
 
    @inline(__always)
    func isOverlap(_ other: LineRange) -> Bool {
        min <= other.max && max >= other.min
    }
    
    @inline(__always)
    func clamp(range: LineRange) -> LineRange {
        let min = self.min.clamp(minValue: range.min, maxValue: range.max)
        let max = self.max.clamp(minValue: range.min, maxValue: range.max)
        
        return LineRange(min: min, max: max)
    }
    
    @inline(__always)
    func trunc(value: Int32) -> Int32 {
        value.clamp(minValue: self.min, maxValue: self.max)
    }
}

extension Int32 {
    
    @inline(__always)
    func clamp(minValue: Int32, maxValue: Int32) -> Int32 {
        Swift.min(Swift.max(self, minValue), maxValue)
    }
    
}
