//
//  ShapeType.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

public typealias ShapeType = Int

public extension ShapeType {
    
    static let subject: Int  = 0b0001
    static let clip: Int     = 0b0010
    static let common: Int   = subject | clip

}
