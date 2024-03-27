//
//  Array.swift
//
//
//  Created by Nail Sharipov on 05.03.2024.
//

extension Array {
    
    @inlinable
    mutating func swapRemove(_ index: Int) {
        if index < self.count - 1 {
            self[index] = self.removeLast()
        } else {
            self.removeLast()
        }
    }
}
