//
//  VersionedIndex.swift
//  
//
//  Created by Nail Sharipov on 22.11.2023.
//

struct VersionedIndex {

    static let empty = VersionedIndex(version: .max, index: .empty)

    let version: UInt32
    let index: DualIndex
    
    var isNotNil: Bool { index.major != .max && index.minor != .max }
}

extension VersionedIndex: Equatable {
    public static func == (lhs: VersionedIndex, rhs: VersionedIndex) -> Bool {
        lhs.version == rhs.version && lhs.index == rhs.index
    }
}
