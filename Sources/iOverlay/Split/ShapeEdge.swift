//
//  ShapeEdge.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iFixFloat
import iShape

public struct ShapeEdge {

    static let zero = ShapeEdge(a: .zero, b: .zero, count: ShapeCount(subj: 0, clip: 0))

    var edge: FixEdge { FixEdge(e0: a, e1: b) }

    // start < end
    public let a: FixVec        // start
    public let b: FixVec        // end
    
    let aBitPack: Int64
    let bBitPack: Int64
    
    let count: ShapeCount
    
    let maxY: Int64
    let minY: Int64

    @inline(__always)
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

    @inline(__always)
    init(parent: ShapeEdge, count: ShapeCount) {
        self.a = parent.a
        self.b = parent.b
        self.minY = parent.minY
        self.maxY = parent.maxY
        self.count = count
        self.aBitPack = parent.aBitPack
        self.bBitPack = parent.bBitPack
    }

    @inline(__always)
    func merge(_ other: ShapeEdge) -> ShapeEdge {
        ShapeEdge(a: a, b: b, count: self.count.add(other.count))
    }

    @inline(__always)
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

    @inline(__always)
    func isEqual(_ other: ShapeEdge) -> Bool {
        let a0 = aBitPack
        let a1 = other.aBitPack
        let b0 = bBitPack
        let b1 = other.bBitPack
        
        return a0 == a1 && b0 == b1
    }

}
