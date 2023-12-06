//
//  VersionedIndex.swift
//  
//
//  Created by Nail Sharipov on 22.11.2023.
//

struct DualIndex: Equatable {
    static let empty = DualIndex(base: .max, node: .max)
    let base: UInt32
    let node: UInt32
}

struct VersionedIndex {

    static let empty = VersionedIndex(version: .max, index: .empty)

    let version: UInt32
    let index: DualIndex
    
    var isNotNil: Bool { index.base != .max && index.node != .max }
}
