//
//  CompositeIndex.swift
//  
//
//  Created by Nail Sharipov on 22.11.2023.
//

struct CompositeIndex: Equatable {

    static let empty = CompositeIndex(main: .max, list: .max)
    
    let main: UInt32
    let list: UInt32
    
    var isValid: Bool { main != .max && list != .max }
}
