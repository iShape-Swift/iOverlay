//
//  Int.swift
//
//
//  Created by Nail Sharipov on 27.03.2024.
//

extension Int {
    
    private var logTwo: Int {
        Int.bitWidth - self.leadingZeroBitCount
    }
    
    var logSqrt: Int {
        assert(self >= 0)
        
        let n = (self.logTwo + 1) >> 1
        return 1 << n
    }

}
