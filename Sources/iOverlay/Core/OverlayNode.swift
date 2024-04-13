//
//  OverlayNode.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

struct OverlayNode {
        
    var indices: [Int]

    @inline(__always)
    func other(index: Int) -> Int {
        assert(indices.count == 2)
        return indices[0] == index ? indices[1] : indices[0]
    }
}

