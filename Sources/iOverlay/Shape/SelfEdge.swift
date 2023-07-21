//
//  SelfEdge.swift
//  
//
//  Created by Nail Sharipov on 20.07.2023.
//

import iFixFloat
import iShape


public struct SelfEdge {
        
    @usableFromInline
    static let zero = SelfEdge(a: .zero, b: .zero, n: 0)
    
    @inlinable
    var edge: FixEdge { FixEdge(e0: a, e1: b) }
    
    @inlinable
    var bound: FixBnd { FixBnd(p0: a, p1: b) }
    
    // start < end
    public let a: FixVec        // start
    public let b: FixVec        // end
    public let n: Int
    
    @inlinable
    init(a: FixVec, b: FixVec, n: Int) {
        self.a = a
        self.b = b
        self.n = n
    }
    
    @inlinable
    init(parent: SelfEdge, n: Int) {
        self.a = parent.a
        self.b = parent.b
        self.n = n
    }
    
    @inlinable
    func cross(_ other: SelfEdge) -> EdgeCross {
        edge.cross(other.edge)
    }
}

extension SelfEdge: Equatable, Hashable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.a == rhs.a && lhs.b == rhs.b
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(a.bitPack)
        hasher.combine(b.bitPack)
    }

    @inlinable
    func isLess(_ other: FixEdge) -> Bool {
        let a0 = a.bitPack
        let a1 = other.e0.bitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            let b0 = b.bitPack
            let b1 = other.e1.bitPack
            
            return b0 < b1
        }
    }

    @inlinable
    func isEqual(_ other: FixEdge) -> Bool {
        let a0 = a.bitPack
        let a1 = other.e0.bitPack
        let b0 = b.bitPack
        let b1 = other.e1.bitPack
        
        return a0 == a1 && b0 == b1
    }
    
    @inlinable
    func isLess(_ other: SelfEdge) -> Bool {
        let a0 = a.bitPack
        let a1 = other.a.bitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            let b0 = b.bitPack
            let b1 = other.b.bitPack
            
            return b0 < b1
        }
    }

    @inlinable
    func isEqual(_ other: SelfEdge) -> Bool {
        let a0 = a.bitPack
        let a1 = other.a.bitPack
        let b0 = b.bitPack
        let b1 = other.b.bitPack
        
        return a0 == a1 && b0 == b1
    }
}
