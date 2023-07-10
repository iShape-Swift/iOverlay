//
//  Pin.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iFixFloat
import iShape

@usableFromInline
struct PointStone {
    
    @usableFromInline
    let m: MileStone
    @usableFromInline
    let p: FixVec
    
    @inlinable
    init(m: MileStone, p: FixVec) {
        self.m = m
        self.p = p
    }
}

public enum PinType {
    case empty
    
    case into
    case into_empty
    case empty_into
    case into_out
    
    case out
    case empty_out
    case out_empty
    case out_into
}

public struct Pin {

    public static let zero = Pin(p: .zero, mA: .zero, mB: .zero)
    
    public let i: Int
    public let p: FixVec
    public let mA: MileStone
    public let mB: MileStone
    public internal (set) var type: PinType = .empty
    
#if DEBUG
    public var a0: FixFloat = 0
    public var a1: FixFloat = 0
#endif
    
    init(i: Int = 0, p: FixVec, mA: MileStone, mB: MileStone, type: PinType = .empty) {
        self.i = i
        self.p = p
        self.mA = mA
        self.mB = mB
        self.type = type
    }
    
    init(i: Int, pin: Pin) {
        self.i = i
        self.p = pin.p
        self.mA = pin.mA
        self.mB = pin.mB
        self.type = pin.type
    }
    
    @inlinable
    var a: PointStone {
        .init(m: mA, p: p)
    }

    @inlinable
    var b: PointStone {
        .init(m: mB, p: p)
    }
}

extension Array where Element == Pin {
    
    @inlinable
    func next(pin: Pin) -> Pin {
        let i = pin.i + 1
        let next = i == count ? 0 : i
        return self[next]
    }
}
