//
//  DualIndex.swift
//
//
//  Created by Nail Sharipov on 07.12.2023.
//

public struct DualIndex: Equatable {
    public static let empty = DualIndex(major: .max, minor: .max)
    public let major: UInt32
    public let minor: UInt32
    
    public init(major: UInt32, minor: UInt32) {
        self.major = major
        self.minor = minor
    }
}
