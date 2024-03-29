//
//  FixEdge.swift
//
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iShape
import iFixFloat

public enum CrossResult {
    
    case pure(Point)        // simple intersection with no overlaps or common points
    case end_overlap
    case equal
    case overlap
    case this_end(Point)
    case scan_end(Point)
}

extension XSegment {

    func debugCross(_ other: XSegment) -> CrossResult? {
        let testX =
        // a > all other
        self.a.x > other.a.x && self.a.x > other.b.x &&
        // b > all other
        self.b.x > other.a.x && self.b.x > other.b.x ||
        // a < all other
        self.a.x < other.a.x && self.a.x < other.b.x &&
        // b < all other
        self.b.x < other.a.x && self.b.x < other.b.x
        
        guard !testX else {
            return nil
        }
        
        return self.scanCross(other)
    }
    
    
    func scanCross(_ other: XSegment) -> CrossResult? {
        // by this time segments already at intersection range by x
#if DEBUG
        let testX =
        // a > all other
        self.a.x > other.a.x && self.a.x > other.b.x &&
        // b > all other
        self.b.x > other.a.x && self.b.x > other.b.x ||
        // a < all other
        self.a.x < other.a.x && self.a.x < other.b.x &&
        // b < all other
        self.b.x < other.a.x && self.b.x < other.b.x
        
        assert(!testX)
#endif
        
        
        let testY =
        // a > all other
        self.a.y > other.a.y && self.a.y > other.b.y &&
        // b > all other
        self.b.y > other.a.y && self.b.y > other.b.y ||
        // a < all other
        self.a.y < other.a.y && self.a.y < other.b.y &&
        // b < all other
        self.b.y < other.a.y && self.b.y < other.b.y
        
        guard !testY else {
            return nil
        }
        
        let isEnd0 = self.a == other.a || self.a == other.b
        let isEnd1 = self.b == other.a || self.b == other.b
  
        if isEnd0 && isEnd1 {
            return .equal
        }
        
        let a0 = FixVec(self.a)
        let b0 = FixVec(self.b)

        let a1 = FixVec(other.a)
        let b1 = FixVec(other.b)
        
        
        let a0b0a1 = Triangle.clockDirection(p0: a0, p1: b0, p2: a1)
        let a0b0b1 = Triangle.clockDirection(p0: a0, p1: b0, p2: b1)

        let a1b1a0 = Triangle.clockDirection(p0: a1, p1: b1, p2: a0)
        let a1b1b0 = Triangle.clockDirection(p0: a1, p1: b1, p2: b0)
        
        
        let isCollinear = a0b0a1 == 0 && a0b0b1 == 0 && a1b1a0 == 0 && a1b1b0 == 0

        if (isEnd0 || isEnd1) && isCollinear {
            let dotProduct: Int64
            if isEnd0 {
                dotProduct = (a0 - b0).dotProduct(a0 - (a0 == a1 ? b1 : a1))
            } else {
                dotProduct = (b0 - a0).dotProduct(b0 - (b0 == a1 ? b1 : a1))
            }
            if dotProduct < 0 {
                // only one common end
                return nil
            } else {
                return .end_overlap
            }
        } else if isCollinear {
            return .overlap
        } else if isEnd0 || isEnd1 {
            assert(!(isEnd0 && isEnd1))
            return nil
        }
        
        let notSame0 = a0b0a1 != a0b0b1
        let notSame1 = a1b1a0 != a1b1b0
        
        guard notSame0 && notSame1 else {
            return nil
        }
        
        let p = Self.crossPoint(a0: a0, a1: b0, b0: a1, b1: b1)
        
        // still can be common ends cause rounding
        // snap to nearest end with radius 1, (1^2 + 1^2 == 2)
        
        let ra0 = a0.sqrDistance(p)
        let rb0 = b0.sqrDistance(p)
        
        let ra1 = a1.sqrDistance(p)
        let rb1 = b1.sqrDistance(p)
        
        if ra0 <= 2 || ra1 <= 2 || rb0 <= 2 || rb1 <= 2 {
            let r0 = min(ra0, rb0)
            let r1 = min(ra1, rb1)
            
            if r0 <= r1 {
                let p = ra0 < rb0 ? a0 : b0
                return .this_end(Point(p))
            } else {
                let p = ra1 < rb1 ? a1 : b1
                return .scan_end(Point(p))
            }
        } else {
            return .pure(Point(p))
        }
    }
        /*
        let a0 = FixVec(self.a)
        let a1 = FixVec(self.b)
        
        let b0 = FixVec(other.a)
        let b1 = FixVec(other.b)
        
        let a0Area = Triangle.unsafeAreaTwo(p0: b0, p1: a0, p2: b1)
        let a1Area = Triangle.unsafeAreaTwo(p0: b0, p1: a1, p2: b1)
        
        guard a0Area != 0 || a1Area != 0 else {
            // same line
            return Self.sameLineOverlay(self, other)
        }
        
        let comA0 = a0 == b0 || a0 == b1
        let comA1 = a1 == b0 || a1 == b1
        
        let hasSameEnd = comA0 || comA1
        
        guard !hasSameEnd else {
            return nil
        }
        
        guard a0Area != 0 else {
            if other.isBoxContain(self.a) {
                return EdgeCross(type: .end_a, point: self.a)
            } else {
                return nil
            }
        }
        
        guard a1Area != 0 else {
            if other.isBoxContain(self.b) {
                return EdgeCross(type: .end_a, point: self.b)
            } else {
                return nil
            }
        }
        
        let b0Area = Triangle.unsafeAreaTwo(p0: a0, p1: b0, p2: a1)
        
        guard b0Area != 0 else {
            if self.isBoxContain(other.a) {
                return EdgeCross(type: .end_b, point: other.a)
            } else {
                return nil
            }
        }
        
        let b1Area = Triangle.unsafeAreaTwo(p0: a0, p1: b1, p2: a1)
        
        guard b1Area != 0 else {
            if self.isBoxContain(other.b) {
                return EdgeCross(type: .end_b, point: other.b)
            } else {
                return nil
            }
        }
        
        // areas of triangles must have opposite sign
        let areaACondition = a0Area > 0 && a1Area < 0 || a0Area < 0 && a1Area > 0
        let areaBCondition = b0Area > 0 && b1Area < 0 || b0Area < 0 && b1Area > 0
        
        guard areaACondition && areaBCondition else {
            return nil
        }
        
        let f = Self.crossPoint(a0: a0, a1: a1, b0: b0, b1: b1)
        let p = Point(f)
        
        assert(self.isBoxContain(p))
        assert(other.isBoxContain(p))
        
        // still can be common ends cause rounding
        // snap to nearest end with radius 1, (1^2 + 1^2 == 2)
        
        let ra0 = a0.sqrDistance(f)
        let ra1 = a1.sqrDistance(f)
        
        let rb0 = b0.sqrDistance(f)
        let rb1 = b1.sqrDistance(f)
        
        if ra0 <= 2 || ra1 <= 2 || rb0 <= 2 || rb1 <= 2 {
            let ra = min(ra0, ra1)
            let rb = min(rb0, rb1)
            
            if ra <= rb {
                let a = ra0 < ra1 ? a0 : a1
                return EdgeCross(type: .end_a, point: Point(a))
            } else {
                let b = rb0 < rb1 ? b0 : b1
                return EdgeCross(type: .end_b, point: Point(b))
            }
        } else {
            return EdgeCross(type: .pure, point: p)
        }
    }
    */
    
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
    /*
    private func isBoxContain(_ p: Point) -> Bool {
        let xContain = a.x <= p.x && p.x <= b.x // a.x <= b.x by definition of xSegment
        let yContain = a.y <= p.y && p.y <= b.y || b.y <= p.y && p.y <= a.y
        return xContain && yContain
    }
    
    private func isBoxContain(_ edge: XSegment) -> Bool {
        let xContain = a.x <= edge.a.x && edge.b.x <= b.x
        guard xContain else {
            return false
        }
        
        let syMin: Int32
        let syMax: Int32
        if a.y <= b.y {
            syMin = a.y
            syMax = b.y
        } else {
            syMin = b.y
            syMax = a.y
        }
        
        let eyMin: Int32
        let eyMax: Int32
        if edge.a.y <= edge.b.y {
            eyMin = edge.a.y
            eyMax = edge.b.y
        } else {
            eyMin = edge.b.y
            eyMax = edge.a.y
        }
        
        return syMin <= eyMin && eyMax <= syMax
    }
    
    
    private static func sameLineOverlay(_ edgeA: XSegment, _ edgeB: XSegment) -> EdgeCross? {
        let isA = edgeA.isBoxContain(edgeB) // b inside a
        let isB = edgeB.isBoxContain(edgeA) // a inside b
        
        guard !(isA && isB) else {
            // edges are equal
            return nil
        }
        
        if isB {
            // a inside b
            return edgeB.solveInside(other: edgeA, end: .end_a, overlay: .overlay_a)
        }
        
        let hasSameEnd = edgeA.a == edgeB.a || edgeA.a == edgeB.b || edgeA.b == edgeB.a || edgeA.b == edgeB.b
        
        guard !hasSameEnd else {
            return nil
        }
        
        assert(!isA && !isB)
        
        // penetrate
        
        let ap = edgeA.isBoxContain(edgeB.a) ? edgeB.a : edgeB.b
        let bp = edgeB.isBoxContain(edgeA.a) ? edgeA.a : edgeA.b
        
        if Point.xLineCompare(a: ap, b: bp) {
            return EdgeCross(type: .penetrate, point: ap, second: bp)
        } else {
            return EdgeCross(type: .penetrate, point: bp, second: ap)
        }
    }
    
    private func solveInside(other: XSegment, end: EdgeCrossType, overlay: EdgeCrossType) -> EdgeCross {
        let isBe0 = other.a == self.a || other.a == self.b
        let isBe1 = other.b == self.a || other.b == self.b
        
        if isBe0 {
            // first point is common
            return EdgeCross(type: end, point: other.b)
        } else if isBe1 {
            // second point is common
            return EdgeCross(type: end, point: other.a)
        } else {
            // no common points
            return EdgeCross(type: overlay, point: .zero)
        }
    }
    */
}
private extension Int64 {
    
    var leadingZeroBitCountIgnoreSign: Int {
        abs(self).leadingZeroBitCount - 1
    }
}
