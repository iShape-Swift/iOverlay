//
//  LineRange.swift
//
//
//  Created by Nail Sharipov on 06.12.2023.
//

public struct LineRange {
    let min: Int32
    let max: Int32
}

public extension LineRange {
 
    func isOverlap(_ other: LineRange) -> Bool {
        min <= other.max && max >= other.min
    }
    
}
