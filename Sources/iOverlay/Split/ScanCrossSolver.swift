//
//  ScanCrossSolver.swift
//
//
//  Created by Nail Sharipov on 30.03.2024.
//

import iFixFloat

public enum CrossResult {
    case pureExact(Point)
    case pureRound(Point)
    case endOverlap
    case overlap
    case targetEndExact(Point)
    case targetEndRound(Point)
    case otherEndExact(Point)
    case otherEndRound(Point)
}

struct ScanCrossSolver {
    
    static func isValid(scan: XSegment, this: XSegment) -> Bool {
        let isOutdated = scan.b < this.a
        let isBehind = scan < this
        
        return !isOutdated && isBehind
    }
    
    static func debugCross(target: XSegment, other: XSegment) -> CrossResult? {
        let testX =
        // a > all other
        target.a.x > other.a.x && target.a.x > other.b.x &&
        // b > all other
        target.b.x > other.a.x && target.b.x > other.b.x ||
        // a < all other
        target.a.x < other.a.x && target.a.x < other.b.x &&
        // b < all other
        target.b.x < other.a.x && target.b.x < other.b.x
        
        guard !testX else {
            return nil
        }
        
        return self.cross(target: target, other: other)
    }
    
    static func cross(target: XSegment, other: XSegment) -> CrossResult? {
        // by this time segments already at intersection range by x
#if DEBUG
        let testX =
        // a > all other
        target.a.x > other.a.x && target.a.x > other.b.x &&
        // b > all other
        target.b.x > other.a.x && target.b.x > other.b.x ||
        // a < all other
        target.a.x < other.a.x && target.a.x < other.b.x &&
        // b < all other
        target.b.x < other.a.x && target.b.x < other.b.x
        
        assert(!testX)
#endif
        
        
        let testY =
        // a > all other
        target.a.y > other.a.y && target.a.y > other.b.y &&
        // b > all other
        target.b.y > other.a.y && target.b.y > other.b.y ||
        // a < all other
        target.a.y < other.a.y && target.a.y < other.b.y &&
        // b < all other
        target.b.y < other.a.y && target.b.y < other.b.y
        
        guard !testY else {
            return nil
        }
        
        let isAA = target.a == other.a
        let isAB = target.a == other.b
        let isBA = target.b == other.a
        let isBB = target.b == other.b
        
        let isEnd0 = isAA || isAB
        let isEnd1 = isBA || isBB

        let a0b0a1 = Triangle.clockDirection(p0: target.a, p1: target.b, p2: other.a)
        let a0b0b1 = Triangle.clockDirection(p0: target.a, p1: target.b, p2: other.b)

        let a1b1a0 = Triangle.clockDirection(p0: other.a, p1: other.b, p2: target.a)
        let a1b1b0 = Triangle.clockDirection(p0: other.a, p1: other.b, p2: target.b)

        let isCollinear = a0b0a1 | a0b0b1 | a1b1a0 | a1b1b0 == 0

        if isEnd0 || isEnd1 {
            if isCollinear {
                let dotProduct: Int64

                if isEnd0 {
                    dotProduct = target.a.subtract(target.b).dotProduct(target.a.subtract(isAA ? other.b : other.a))
                } else {
                    dotProduct = target.b.subtract(target.a).dotProduct(target.a.subtract(isBA ? other.b : other.a))
                }
                if dotProduct >= 0 {
                    return .endOverlap
                }
            }
            
            return nil
        } else if isCollinear {
            return .overlap
        }
        
        let notSame0 = a0b0a1 != a0b0b1
        let notSame1 = a1b1a0 != a1b1b0
        
        guard notSame0 && notSame1 else {
            return nil
        }

        if a0b0a1 & a0b0b1 & a1b1a0 & a1b1b0 == 0 {
            // one end is on the other edge
            if a0b0a1 == 0 {
                return .otherEndExact(other.a)
            } else if a0b0b1 == 0 {
                return .otherEndExact(other.b)
            } else if a1b1a0 == 0 {
                return .targetEndExact(target.a)
            }
            
            return .targetEndExact(target.b)
        }
        
        let a0 = FixVec(target.a)
        let b0 = FixVec(target.b)

        let a1 = FixVec(other.a)
        let b1 = FixVec(other.b)

        let p = Self.crossPoint(a0: a0, a1: b0, b0: a1, b1: b1)
        
        if Triangle.isLine(p0: a0, p1: p, p2: b0) && Triangle.isLine(p0: a1, p1: p, p2: b1) {
            return .pureExact(Point(p))
        }
        
        // still can be common ends because of rounding
        // snap to nearest end with r (1^2 + 1^2 == 2)

        let ra0 = a0.sqrDistance(p)
        let rb0 = b0.sqrDistance(p)
        
        let ra1 = a1.sqrDistance(p)
        let rb1 = b1.sqrDistance(p)
        
        if ra0 <= 2 || ra1 <= 2 || rb0 <= 2 || rb1 <= 2 {
            let r0 = min(ra0, rb0)
            let r1 = min(ra1, rb1)
            
            if r0 <= r1 {
                let p = ra0 < rb0 ? a0 : b0
                
                // ignore if it's a clean point
                if Triangle.isNotLine(p0: a1, p1: p, p2: b1) {
                    return .targetEndRound(Point(p))
                }
            } else {
                let p = ra1 < rb1 ? a1 : b1
                
                // ignore if it's a clean point
                if Triangle.isNotLine(p0: a0, p1: p, p2: b0) {
                    return .otherEndRound(Point(p))
                }
            }
        }

        return .pureRound(Point(p))
    }
    
    private static func crossPoint(a0: FixVec, a1: FixVec, b0: FixVec, b1: FixVec) -> FixVec {
        /// edges are not parralel
        /// FixVec(Int64, Int64) where abs(x) and abs(y) < 2^30
        /// So the result must be also be in range of 2^30
        
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
        
        // move a0.x to 0
        // move all by a0.x
        let a1x = a1.x - a0.x
        let b0x = b0.x - a0.x
        let b1x = b1.x - a0.x
        
        // move a0.y to 0
        // move all by a0.y
        let a1y = a1.y - a0.y
        let b0y = b0.y - a0.y
        let b1y = b1.y - a0.y
        
        let dyB = b0y - b1y
        let dxB = b0x - b1x
        
        // let xyA = 0
        let xyB = b0x * b1y - b0y * b1x
        
        let x0: Int64
        let y0: Int64
        
        // a1y and a1x cannot be zero simultaneously, because we will get edge a0<>a1 zero length and it is impossible
        
        if a1x == 0 {
            // dxB is not zero because it will be parallel case and it's impossible
            x0 = 0
            y0 = xyB / dxB
        } else if a1y == 0 {
            // dyB is not zero because it will be parallel case and it's impossible
            y0 = 0
            x0 = -xyB / dyB
        } else {
            // TODO switch to 128 bit math
            // multiply denominator and discriminant by same value to increase precision
            
            let xym = xyB.leadingZeroBitCountIgnoreSign
            
            // x
            let xd = a1y * dxB
            let xdm = xd.leadingZeroBitCountIgnoreSign
            
            let xm = min(30, min(xym, xdm))
            let divX = (xd << xm) / a1x - (dyB << xm)
            
            x0 = (xyB << xm) / divX
            
            // y
            
            let yd = a1x * dyB
            let ydm = yd.leadingZeroBitCountIgnoreSign
            
            let ym = min(30, min(xym, ydm))
            let divY = (dxB << ym) - (yd << ym) / a1y
            
            y0 = (xyB << ym) / divY
        }
        
        let x = x0 + a0.x
        let y = y0 + a0.y
        
        return FixVec(x, y)
    }

}

private extension Int64 {
    
    var leadingZeroBitCountIgnoreSign: Int {
        abs(self).leadingZeroBitCount - 1
    }
}
