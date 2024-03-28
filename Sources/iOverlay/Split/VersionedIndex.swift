//
//  VersionedIndex.swift
//  
//
//  Created by Nail Sharipov on 22.11.2023.
//

struct DualIndex: Equatable {
    static let empty = DualIndex(major: .max, minor: .max)
    let major: UInt32
    let minor: UInt32
    
    init(major: UInt32, minor: UInt32) {
        self.major = major
        self.minor = minor
    }
}

extension DualIndex: Comparable {
    static func < (lhs: DualIndex, rhs: DualIndex) -> Bool {
        lhs.major < rhs.major || lhs.major == rhs.major && lhs.minor < rhs.minor
    }
}

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
