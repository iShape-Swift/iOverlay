//
//  BoolShape+Edge.swift
//  
//
//  Created by Nail Sharipov on 21.07.2023.
//

import iShape
import iFixFloat

extension Array where Element == SelfEdge {
    
    func lastNodeIndex(index: Int) -> Int {
        let a = self[index].a
        var i = index + 1
        while i < count {
            if a != self[i].a {
                return i
            }
            i += 1
        }
        return i
    }

}
