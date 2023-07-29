//
//  OverlayNode.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

struct OverlayNode {
        
    var data0: Int
    var data1: Int
    var count: Int

    @inlinable
    func other(index: Int) -> Int {
        assert(count == 2)
        return data0 == index ? data1 : data0
    }
    
}

