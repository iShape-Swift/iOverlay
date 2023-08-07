//
//  ShapeEdge+Sort.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape

//// All operations expect the array to be sorted ascending by 'a' of SelfEdge
extension Array where Element == ShapeEdge {

    func isAsscending() -> Bool {
        guard count > 1 else {
            return true
        }
        
        var i = 1
        var e0 = self[0]
        while i < count {
            let ei = self[i]
            assert(e0.a != e0.b)
            if !e0.isLess(ei) {
                return false
            }
            e0 = ei
            i += 1
        }
        
        return true
    }
}
