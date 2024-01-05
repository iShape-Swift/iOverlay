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
        let min = Swift.max(range.min, self.min)
        let max = Swift.min(range.max, self.max)
        
        return LineRange(min: min, max: max)
    }
}
