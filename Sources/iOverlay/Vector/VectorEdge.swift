//
//  Vector.swift
//
//
//  Created by Nail Sharipov on 30.01.2024.
//

import iFixFloat

public typealias SideFill = UInt8

public extension SideFill {
    
    static let subjLeft: UInt8      = 0b0001
    static let subjRight: UInt8     = 0b0010
    static let clipLeft: UInt8      = 0b0100
    static let clipRight: UInt8     = 0b1000

    static let subjLeftAndRight: UInt8 = subjLeft | subjRight
    static let clipLeftAndRight: UInt8 = clipLeft | clipRight
    
    func reverse() -> SideFill {
        let subjLeft = self & .subjLeft
        let subjRight = self & .subjRight
        let clipLeft = self & .clipLeft
        let clipRight = self & .clipRight
        
        return (subjLeft << 1) | (subjRight >> 1) | (clipLeft << 1) | (clipRight >> 1)
    }
    
    init(fill: SideFill, a: FixVec, b: FixVec) {
        if a.bitPack < b.bitPack {
            self = fill
        } else {
            self = fill.reverse()
        }
    }
    
}

public struct VectorEdge: Equatable {

    public private (set) var fill: SideFill
    public private (set) var a: FixVec
    public private (set) var b: FixVec
    
    mutating func reverse() {
        let c = self.a
        self.a = self.b
        self.b = c

        self.fill = self.fill.reverse()
    }
    
}

public typealias VectorPath = [VectorEdge]

public typealias VectorShape = [VectorPath]
