//
//  ShapeEdge.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape

public struct ShapeEdge {
        
    @usableFromInline
    static let zero = ShapeEdge(a: .zero, b: .zero, count: ShapeCount(subj: 0, clip: 0))

    @inlinable
    var edge: FixEdge { FixEdge(e0: a, e1: b) }

    // start < end
    public let a: FixVec        // start
    public let b: FixVec        // end
    
    @usableFromInline
    let aBitPack: Int64
    
    @usableFromInline
    let bBitPack: Int64
    
    public let count: ShapeCount
    
    @usableFromInline
    let maxY: Int64
    @usableFromInline
    let minY: Int64

    @inlinable
    init(a: FixVec, b: FixVec, count: ShapeCount) {
        let aBitPack = a.bitPack
        let bBitPack = b.bitPack
        
        if aBitPack <= bBitPack {
            self.a = a
            self.b = b
            self.aBitPack = aBitPack
            self.bBitPack = bBitPack
        } else {
            self.a = b
            self.b = a
            self.aBitPack = bBitPack
            self.bBitPack = aBitPack
        }
        
        if a.y < b.y {
            maxY = b.y
            minY = a.y
        } else {
            maxY = a.y
            minY = b.y
        }
        
        self.count = count
    }
    
    @inlinable
    init(parent: ShapeEdge, count: ShapeCount) {
        self.a = parent.a
        self.b = parent.b
        self.minY = parent.minY
        self.maxY = parent.maxY
        self.count = count
        self.aBitPack = parent.aBitPack
        self.bBitPack = parent.bBitPack
    }
    
    @inlinable
    func merge(_ other: ShapeEdge) -> ShapeEdge {
        ShapeEdge(a: a, b: b, count: self.count.add(other.count))
    }

    @inlinable
    func isLess(_ other: ShapeEdge) -> Bool {
        let a0 = aBitPack
        let a1 = other.aBitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            let b0 = bBitPack
            let b1 = other.bBitPack
            
            return b0 < b1
        }
    }
    
    @inlinable
    func isLessOrEqual(_ other: ShapeEdge) -> Bool {
        let a0 = aBitPack
        let a1 = other.aBitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            let b0 = bBitPack
            let b1 = other.bBitPack
            
            return b0 <= b1
        }
    }
    
    @inlinable
    func isEqual(_ other: ShapeEdge) -> Bool {
        let a0 = aBitPack
        let a1 = other.aBitPack
        let b0 = bBitPack
        let b1 = other.bBitPack
        
        return a0 == a1 && b0 == b1
    }

}
