//
//  BoolShape+Fix.swift
//  
//
//  Created by Nail Sharipov on 25.07.2023.
//

import iShape
import iFixFloat

public extension BoolShape {
    
    mutating func shapes() -> [FixPath] {
        
        _ = self.fix()
        self.sortByAngle()
        
        return []
    }
    
}
