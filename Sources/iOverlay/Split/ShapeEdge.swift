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

    var count: ShapeCount
    
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
        self.count = count
    }

    @inline(__always)
    init(parent: ShapeEdge, count: ShapeCount) {
        self.a = parent.a
        self.b = parent.b
        self.count = count
        self.aBitPack = parent.aBitPack
        self.bBitPack = parent.bBitPack
    }

    @inline(__always)
    func isLess(_ other: ShapeEdge) -> Bool {
        if aBitPack != other.aBitPack {
            return aBitPack < other.aBitPack
        } else {
            return bBitPack < other.bBitPack
        }
    }

    @inline(__always)
    func isEqual(_ other: ShapeEdge) -> Bool {
        aBitPack == other.aBitPack && bBitPack == other.bBitPack
    }

}
