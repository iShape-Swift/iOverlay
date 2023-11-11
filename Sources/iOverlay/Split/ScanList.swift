//
//  ScanList.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iShape
import iFixFloat

struct ScanList {
    
    private var items: [Int]
    
    var count: Int {
        items.count
    }
    
    subscript(index: Int) -> Int {
        items[index]
    }

    init(count: Int) {
        items = [Int]()
        let capacity = 2 * Int(Double(count).squareRoot())
        items.reserveCapacity(capacity)
    }

    mutating func add(index: Int) {
        guard !items.contains(where: { $0 == index }) else {
            return
        }
        items.append(index)
    }

    mutating func clear() {
        items.removeAll()
    }

    mutating func removeByReplace(index: Int) {
        if index + 1 < items.count {
            items[index] = items.removeLast()
        } else {
            items.removeLast()
        }
    }
    
}
