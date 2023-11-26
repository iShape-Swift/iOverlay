//
//  ScanList.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iShape
import iFixFloat

struct ScanList {
    
    private var items: [CompositeIndex]
    
    var count: Int {
        items.count
    }
    
    @inline(__always)
    subscript(index: Int) -> CompositeIndex {
        items.withUnsafeBufferPointer { buffer in
            buffer[index]
        }
    }

    init(capacity: Int) {
        items = [CompositeIndex]()
        items.reserveCapacity(capacity)
    }

    mutating func add(index: CompositeIndex) {
        guard !items.contains(where: { $0 == index }) else {
            return
        }
        items.append(index)
    }
    
    mutating func unsafeAdd(index: CompositeIndex) {
        items.append(index)
    }

    mutating func clear() {
        items.removeAll(keepingCapacity: true)
    }

    mutating func removeBySwap(index: Int) {
        if index < items.count - 1 {
            items[index] = items.removeLast()
        } else {
            items.removeLast()
        }
    }
    
}
