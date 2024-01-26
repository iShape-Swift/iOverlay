//
//  Int.swift
//  
//
//  Created by Nail Sharipov on 02.01.2024.
//

extension Int {
    
    @inline(__always)
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
