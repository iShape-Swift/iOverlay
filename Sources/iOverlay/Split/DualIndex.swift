//
//  DualIndex.swift
//
//
//  Created by Nail Sharipov on 07.12.2023.
//

struct DualIndex: Equatable {
    static let empty = DualIndex(major: .max, minor: .max)
    let major: UInt32
    let minor: UInt32
}
