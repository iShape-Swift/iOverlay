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

    var count: ShapeCount
    
    init(a: FixVec, b: FixVec, count: ShapeCount) {
        let aBitPack = a.bitPack
        let bBitPack = b.bitPack
        
        if aBitPack <= bBitPack {
            self.a = a
            self.b = b
        } else {
            self.a = b
            self.b = a
        }
        self.count = count
    }

    @inline(__always)
    init(parent: ShapeEdge, count: ShapeCount) {
        self.a = parent.a
        self.b = parent.b
        self.count = count
    }

    @inline(__always)
    func isLess(_ other: ShapeEdge) -> Bool {
        let a0 = self.a.bitPack
        let a1 = other.a.bitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            return self.b.bitPack < other.b.bitPack
        }
    }

    @inline(__always)
    func isEqual(_ other: ShapeEdge) -> Bool {
        a == other.a && b == other.b
    }

}
