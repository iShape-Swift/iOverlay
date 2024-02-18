//
//  LineRange.swift
//
//
//  Created by Nail Sharipov on 06.12.2023.
//

public struct LineRange {
    
    public let min: Int32
    public let max: Int32
    
    public init(min: Int32, max: Int32) {
        self.min = min
        self.max = max
    }
}

public extension LineRange {
 
    func isOverlap(_ other: LineRange) -> Bool {
        min <= other.max && max >= other.min
    }
    
    func clamp(range: LineRange) -> LineRange {
        let min = self.min.clamp(minValue: range.min, maxValue: range.max)
        let max = self.max.clamp(minValue: range.min, maxValue: range.max)
        
        return LineRange(min: min, max: max)
    }
    
    func trunc(value: Int32) -> Int32 {
        value.clamp(minValue: self.min, maxValue: self.max)
    }
}

extension Int32 {
    
    func clamp(minValue: Int32, maxValue: Int32) -> Int32 {
        Swift.min(Swift.max(self, minValue), maxValue)
    }
    
}
