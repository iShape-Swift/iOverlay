//
//  ShapeType.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

public typealias ShapeType = UInt8

public extension ShapeType {
    
    static let subject: UInt8  = 0b0001
    static let clip: UInt8     = 0b0010
    static let common: UInt8   = subject | clip

}
