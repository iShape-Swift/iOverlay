//
//  FillMask.swift
//  
//
//  Created by Nail Sharipov on 28.07.2023.
//

public typealias FillMask = Int

public extension FillMask {
    
    static let subjectTop       = 0b0001
    static let subjectBottom    = 0b0010
    static let clipTop          = 0b0100
    static let clipBottom       = 0b1000
    
}
