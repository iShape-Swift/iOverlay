//
//  CrossSolver.swift
//
//
//  Created by Nail Sharipov on 30.03.2024.
//

import iFixFloat

typealias OverlayMask = UInt8

extension OverlayMask {
    static let targetA: UInt8       = 0b0001
    static let targetB: UInt8       = 0b0010
    static let otherA: UInt8        = 0b0100
    static let otherB: UInt8        = 0b1000

    var isTargetA: Bool {
        self & Self.targetA == Self.targetA
    }
    
    var isTargetB: Bool {
        self & Self.targetB == Self.targetB
    }

    var isOtherA: Bool {
        self & Self.otherA == Self.otherA
    }
    
    var isOtherB: Bool {
        self & Self.otherB == Self.otherB
    }

    init(isTargetA: Bool, isTargetB: Bool, isOtherA: Bool, isOtherB: Bool) {
        let target: UInt8 = (isTargetA ? Self.targetA : 0) | (isTargetB ? Self.targetB : 0)
        let other: UInt8 = (isOtherA ? Self.otherA : 0) | (isOtherB ? Self.otherB : 0)
        self = target | other
    }
}

struct CrossResult {
    let point: Point
    let type: CrossType
    let isRound: Bool
}

enum CrossType {
    case pure
    case targetEnd
    case otherEnd
    case overlap
}

struct CrossSolver {

    static func cross(target: XSegment, other: XSegment) -> CrossResult? {

        // by this time segments already at intersection range by x

        let a0b0a1 = Triangle.clockDirection(p0: target.a, p1: target.b, p2: other.a)
        let a0b0b1 = Triangle.clockDirection(p0: target.a, p1: target.b, p2: other.b)

        let a1b1a0 = Triangle.clockDirection(p0: other.a, p1: other.b, p2: target.a)
        let a1b1b0 = Triangle.clockDirection(p0: other.a, p1: other.b, p2: target.b)
        
        let s = (1 & (a0b0a1 + 1)) + (1 & (a0b0b1 + 1)) + (1 & (a1b1a0 + 1)) + (1 & (a1b1b0 + 1))
        
        guard s != 4 else {
            return CrossResult(point: .zero, type: .overlap, isRound: false)
        }

        let isCross = a0b0a1 != a0b0b1 && a1b1a0 != a1b1b0
        
        guard (s == 0 || s == 1) && isCross else {
            return nil
        }
        
        if s == 0 {
            return Self.middleCross(target: target, other: other)
        }
        
        // end cross
        
        let point: Point
        let type: CrossType
        if a0b0a1 == 0 {
            point = other.a
            type = .otherEnd
        } else if a0b0b1 == 0 {
            point = other.b
            type = .otherEnd
        } else if a1b1a0 == 0 {
            point = target.a
            type = .targetEnd
        } else {
            point = target.b
            type = .targetEnd
        }
        
        return CrossResult(point: point, type: type, isRound: false)
    }
    
    static func overlay(target: XSegment, other: XSegment) -> OverlayMask {
        /// Mark: target and other are collinear
        
        let a0 = FixVec(target.a)
        let b0 = FixVec(target.b)
        let a1 = FixVec(other.a)
        let b1 = FixVec(other.b)
        
        let v1 = b1 - a1

        let aa0 = (a0 - a1).dotProduct(v1).signum()
        let ab0 = (a0 - b1).dotProduct(v1).signum()
        let ba0 = (b0 - a1).dotProduct(v1).signum()
        let bb0 = (b0 - b1).dotProduct(v1).signum()

        let aa1 = -aa0
        let ab1 = -ba0
        let ba1 = -ab0
        let bb1 = -bb0
        
        let isTargetA = aa0 == -ab0 && aa0 != 0
        let isTargetB = ba0 == -bb0 && ba0 != 0

        let isOtherA = aa1 == -ab1 && aa1 != 0
        let isOtherB = ba1 == -bb1 && ba1 != 0
        
        return OverlayMask(isTargetA: isTargetA, isTargetB: isTargetB, isOtherA: isOtherA, isOtherB: isOtherB)
    }
    
    private static func middleCross(target: XSegment, other: XSegment) -> CrossResult {
        let p = Self.crossPoint(target: target, other: other)
        
        if Triangle.isLine(p0: target.a, p1: p, p2: target.b) && Triangle.isLine(p0: other.a, p1: p, p2: other.b) {
            return CrossResult(point: p, type: .pure, isRound: false)
        }
        
        // still can be common ends because of rounding
        // snap to nearest end with r (1^2 + 1^2 == 2)
        
        let ra0 = target.a.sqrDistance(p)
        let rb0 = target.b.sqrDistance(p)
        
        let ra1 = other.a.sqrDistance(p)
        let rb1 = other.b.sqrDistance(p)
        
        if ra0 <= 2 || ra1 <= 2 || rb0 <= 2 || rb1 <= 2 {
            let r0 = min(ra0, rb0)
            let r1 = min(ra1, rb1)
            
            if r0 <= r1 {
                let p = ra0 < rb0 ? target.a : target.b
                
                // ignore if it's a clean point
                if Triangle.isNotLine(p0: other.a, p1: p, p2: other.b) {
                    return CrossResult(point: p, type: .targetEnd, isRound: true)
                }
            } else {
                let p = ra1 < rb1 ? other.a : other.b
                
                // ignore if it's a clean point
                if Triangle.isNotLine(p0: target.a, p1: p, p2: target.b) {
                    return CrossResult(point: p, type: .otherEnd, isRound: true)
                }
            }
        }
        

        return CrossResult(point: p, type: .pure, isRound: true)
    }
    
    private static func crossPoint(target: XSegment, other: XSegment) -> Point {
        /// edges are not parallel
        /// any abs(x) and abs(y) < 2^30
        /// The result must be  < 2^30
        
        /// Classic aproach:
        
        /// let dxA = a0.x - a1.x
        /// let dyB = b0.y - b1.y
        /// let dyA = a0.y - a1.y
        /// let dxB = b0.x - b1.x
        ///
        /// let xyA = a0.x * a1.y - a0.y * a1.x
        /// let xyB = b0.x * b1.y - b0.y * b1.x
        ///
        /// overflow is possible!
        /// let kx = xyA * dxB - dxA * xyB
        ///
        /// overflow is possible!
        /// let ky = xyA * dyB - dyA * xyB
        ///
        /// let divider = dxA * dyB - dyA * dxB
        ///
        /// let x = kx / divider
        /// let y = ky / divider
        ///
        /// return FixVec(x, y)
        
        /// offset approach
        /// move all picture by -a0. Point a0 will be equal (0, 0)

        let a0x = Int64(target.a.x)
        let a0y = Int64(target.a.y)
        
        // move a0.x to 0
        // move all by a0.x
        let a1x = Int64(target.b.x) - a0x
        let b0x = Int64(other.a.x) - a0x
        let b1x = Int64(other.b.x) - a0x
        
        // move a0.y to 0
        // move all by a0.y
        let a1y = Int64(target.b.y) - a0y
        let b0y = Int64(other.a.y) - a0y
        let b1y = Int64(other.b.y) - a0y
        
        let dyB = b0y - b1y
        let dxB = b0x - b1x
        
        // let xyA = 0
        let xyB = b0x * b1y - b0y * b1x
        
        let x0: Int64
        let y0: Int64
        
        // a1y and a1x can not be zero simultaneously, because we will get edge a0<>a1 zero length and it is impossible
        
        if a1x == 0 {
            // dxB is not zero because it will be parallel case and it's impossible
            x0 = 0
            y0 = xyB / dxB
        } else if a1y == 0 {
            // dyB is not zero because it will be parallel case and it's impossible
            y0 = 0
            x0 = -xyB / dyB
        } else {
            // divider
            let div = a1y * dxB - a1x * dyB
            
            // calculate result sign
            let s = div.signum() * xyB.signum()
            let sx = a1x.signum() * s
            let sy = a1y.signum() * s
            
            // use custom u128 bit math with rounding
            let uxyB = UInt64(abs(xyB))
            let udiv = UInt64(abs(div))

            let kx = UInt128.multiply(UInt64(abs(a1x)), uxyB)
            let ky = UInt128.multiply(UInt64(abs(a1y)), uxyB)
            
            let ux = kx.divideWithRounding(by: udiv)
            let uy = ky.divideWithRounding(by: udiv)
            
            // get i64 bit result
            x0 = sx * Int64(ux)
            y0 = sy * Int64(uy)
        }
        
        let x = Int32(x0 + a0x)
        let y = Int32(y0 + a0y)
        
        return Point(x, y)
    }

}


private extension UInt128 {
    
    private static let lastBitIndex = UInt64.bitWidth - 1
    
    func divideWithRounding(by divisor: UInt64) -> UInt64 {
        guard high != 0 else {
            let result = low / divisor
            let remainder = low - result * divisor
            if remainder >= (divisor + 1) >> 1 {
                return result + 1
            } else {
                return result
            }
        }
        
        
        let dn = divisor.leadingZeroBitCount
        let normDivisor = divisor << dn
        var normDividendHigh = high << dn | low >> (UInt64.bitWidth - dn)
        var normDividendLow = low << dn
        
        var quotient: UInt64 = 0
        let one: UInt64 = 1 << Self.lastBitIndex
        
        for _ in 0..<UInt64.bitWidth {
            let bit = (normDividendHigh & one) != 0
            normDividendHigh = (normDividendHigh << 1) | (normDividendLow >> Self.lastBitIndex)
            normDividendLow <<= 1
            quotient <<= 1
            if normDividendHigh >= normDivisor || bit {
                normDividendHigh = normDividendHigh &- normDivisor
                quotient |= 1
            }
        }
        
        // Check remainder for rounding
        let remainder = (normDividendHigh << (UInt64.bitWidth - dn)) | (normDividendLow >> dn)
        if remainder >= (divisor + 1) >> 1 {
            quotient += 1
        }
        
        return quotient
    }
    
}
