//
//  LineRange.swift
//
//
//  Created by Nail Sharipov on 06.12.2023.
//

struct LineRange: Equatable {
    
    let min: Int32
    let max: Int32
    
    var width: Int64 {
        Int64(max) - Int64(min)
    }
    
    @inline(__always)
    init(min: Int32, max: Int32) {
        self.min = min
        self.max = max
    }
}
