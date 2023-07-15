//
//  IntMap.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

struct IntMap {
    
    private let maxValue: Int
    private (set) var keys: [Int]
    private var values: [Int]
    
    @inlinable
    subscript(key: Int) -> Int {
        get {
            assert(0 <= key && key <= maxValue)
            return values[key]
        }
        
        set {
            assert(0 <= key && key <= maxValue)
            let a = values[key]
            if a == Int.min {
                keys.append(key)
            }
            values[key] = newValue
        }
    }
    
    @inlinable
    func get(key: Int, def: Int) -> Int {
        assert(0 <= key && key <= maxValue)
        let a = values[key]
        if a == Int.min {
            return def
        } else {
            return values[key]
        }
    }

    
    @inlinable
    init(maxValue: Int) {
        self.maxValue = maxValue
        values = [Int](repeating: .min, count: maxValue + 1)
        keys = [Int]()
        keys.reserveCapacity(maxValue + 1)
    }
    
    @inlinable
    mutating func removeAll() {
        for key in keys {
            values[key] = .min
        }
        keys.removeAll()
    }
    
}
