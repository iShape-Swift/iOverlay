//
//  FixEdge.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iShape
import iFixFloat

struct EdgeCross {
    
    let type: EdgeCrossType
    let point: FixVec
    let second: FixVec

    @usableFromInline
    init(type: EdgeCrossType, point: FixVec, second: FixVec = .zero) {
        self.type = type
        self.point = point
        self.second = second
    }
}

enum EdgeCrossType {

    case pure               // simple intersection with no overlaps or common points
    case overlay_a          // a is inside b
    case overlay_b          // b is inside a
    case penetrate          // a and b penetrate each other
    case end_a
    case end_b
}

extension ShapeEdge {
    func cross(_ other: ShapeEdge) -> EdgeCross? {
        let a0 = a
        let a1 = b

        let b0 = other.a
        let b1 = other.b

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
            if other.isBoxContain(a0) {
                return EdgeCross(type: .end_a, point: a0)
            } else {
                return nil
            }
        }

        guard a1Area != 0 else {
            if other.isBoxContain(a1) {
                return EdgeCross(type: .end_a, point: a1)
            } else {
                return nil
            }
        }

        let b0Area = Triangle.unsafeAreaTwo(p0: a0, p1: b0, p2: a1)

        guard b0Area != 0 else {
            if self.isBoxContain(b0) {
                return EdgeCross(type: .end_b, point: b0)
            } else {
                return nil
            }
        }

        let b1Area = Triangle.unsafeAreaTwo(p0: a0, p1: b1, p2: a1)

        guard b1Area != 0 else {
            if self.isBoxContain(b1) {
                return EdgeCross(type: .end_b, point: b1)
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

        let p = Self.crossPoint(a0: a0, a1: a1, b0: b0, b1: b1)
        
        assert(self.isBoxContain(p))
        assert(other.isBoxContain(p))
        
        // still can be common ends cause rounding
        let endA = a0 == p || a1 == p
        let endB = b0 == p || b1 == p

        if !endA && !endB {
            return EdgeCross(type: .pure, point: p)
        } else if endA {
            return EdgeCross(type: .end_a, point: p)
        } else if endB {
            return EdgeCross(type: .end_b, point: p)
        }
        
        return nil
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
        
        // a1y and a1x cannot be zero simultaneously, cause we will get edge a0<>a1 zero length and it is impossible
        
        if a1x == 0 {
            // dxB is not zero cause it will be parallel case and it's impossible
            x0 = 0
            y0 = xyB / dxB
        } else if a1y == 0 {
            // dyB is not zero cause it will be parallel case and it's impossible
            y0 = 0
            x0 = -xyB / dyB
        } else {
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

    private func isBoxContain(_ p: FixVec) -> Bool {
        let xContain = a.x <= p.x && p.x <= b.x
        let yContain = a.y <= p.y && p.y <= b.y || b.y <= p.y && p.y <= a.y
        return xContain && yContain
    }
    
    private func isBoxContain(_ edge: ShapeEdge) -> Bool {
        let xContain = a.x <= edge.a.x && edge.b.x <= b.x
        guard xContain else {
            return false
        }
        
        let syMin: Int64
        let syMax: Int64
        if a.y <= b.y {
            syMin = a.y
            syMax = b.y
        } else {
            syMin = b.y
            syMax = a.y
        }
        
        let eyMin: Int64
        let eyMax: Int64
        if edge.a.y <= edge.b.y {
            eyMin = edge.a.y
            eyMax = edge.b.y
        } else {
            eyMin = edge.b.y
            eyMax = edge.a.y
        }

        return syMin <= eyMin && eyMax <= syMax
    }
    
    
    private static func sameLineOverlay(_ edgeA: ShapeEdge, _ edgeB: ShapeEdge) -> EdgeCross? {
        let isA = edgeA.isBoxContain(edgeB) // b inside a
        let isB = edgeB.isBoxContain(edgeA) // a inside b
        
        guard !(isA && isB) else {
            // edges are equal
            return nil
        }
        
        if isA {
            // b inside a
            return edgeA.solveInside(other: edgeB, end: .end_b, overlay: .overlay_b)
        }
        
        if isB {
            // a inside b
            return edgeB.solveInside(other: edgeA, end: .end_a, overlay: .overlay_a)
        }
        
        let hasSameEnd = edgeA.a == edgeB.a || edgeA.a == edgeB.b || edgeA.b == edgeB.a || edgeA.b == edgeB.b
        
        guard !hasSameEnd else {
            return nil
        }
        
        // penetrate
        
        let ap = edgeA.isBoxContain(edgeB.a) ? edgeB.a : edgeB.b
        let bp = edgeB.isBoxContain(edgeA.a) ? edgeA.a : edgeA.b
        
        return EdgeCross(type: .penetrate, point: ap, second: bp)
    }
    
    private func solveInside(other: ShapeEdge, end: EdgeCrossType, overlay: EdgeCrossType) -> EdgeCross {
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
}
private extension Int64 {
    
    var leadingZeroBitCountIgnoreSign: Int {
        abs(self).leadingZeroBitCount - 1
    }
}
