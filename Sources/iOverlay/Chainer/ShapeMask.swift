//
//  ShapeMask.swift
//  
//
//  Created by Nail Sharipov on 18.07.2023.
//

public typealias ShapeMask = Int

public extension ShapeMask {
    
    static let empty    = 0
    static let subject  = 0b01
    static let clip     = 0b10
    static let common   = 0b11
    
}
