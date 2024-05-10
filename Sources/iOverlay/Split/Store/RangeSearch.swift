//
//  RangeSearch.swift
//
//
//  Created by Nail Sharipov on 10.05.2024.
//

extension Array where Element == Int32 {
    
    func findIndex(target: Int32) -> Int {
        var left = 0
        var right = self.count
        
        while left < right {
            let mid = left + ((right - left) >> 1)
            if self[mid] == target {
                return mid
            } else if self[mid] < target {
                left = mid + 1
            } else {
                right = mid
            }
        }
        
        return left
    }
}


struct TestFindIndex {
    static func findIndex(array: [Int32], target: Int32) -> Int {
        array.findIndex(target: target)
    }
}
