//
//  CrossSolver.swift
//  
//
//  Created by Nail Sharipov on 05.03.2024.
//

import iFixFloat

enum CrossType {
    case pure
    case overlap
    case sameEnd
    case notCross
    case equal
}

struct RandomEdge {
    let a: Point
    let b: Point
}

struct CrossSolver {
 
    static func isCross(e0: RandomEdge, e1: RandomEdge) -> CrossType {
        let a0 = FixVec(e0.a)
        let b0 = FixVec(e0.b)
        let a1 = FixVec(e1.a)
        let b1 = FixVec(e1.b)
        return Self.isCross(a0: a0, b0: b0, a1: a1, b1: b1)
    }
    
    static func isCross(a0: FixVec, b0: FixVec, a1: FixVec, b1: FixVec) -> CrossType {
        // box cross
        
        // all x from 1 is less all x from 0
        let boundaryTest = a1.x < a0.x && b1.x < a0.x && a1.x < b0.x && b1.x < b0.x
        // all x from 0 is less all x from 1
        || a0.x < a1.x && b0.x < a1.x && a0.x < b1.x && b0.x < b1.x
        // all y from 1 is less all y from 0
        || a1.y < a0.y && b1.y < a0.y && a1.y < b0.y && b1.y < b0.y
        // all y from 0 is less all y from 1
        || a0.y < a1.y && b0.y < a1.y && a0.y < b1.y && b0.y < b1.y
        
        guard !boundaryTest else {
            return .notCross
        }

        // cross
        
        let a0b0a1 = Triangle.clockDirection(p0: a0, p1: b0, p2: a1)
        let a0b0b1 = Triangle.clockDirection(p0: a0, p1: b0, p2: b1)

        let a1b1a0 = Triangle.clockDirection(p0: a1, p1: b1, p2: a0)
        let a1b1b0 = Triangle.clockDirection(p0: a1, p1: b1, p2: b0)

        let isEnd0 = a0 == a1 || a0 == b1
        let isEnd1 = b0 == a1 || b0 == b1

        guard !(isEnd0 && isEnd1) else {
            return .equal
        }

        let isCollinear = a0b0a1 == 0 && a0b0b1 == 0 && a1b1a0 == 0 && a1b1b0 == 0
        
        if (isEnd0 || isEnd1) && isCollinear {
            let dotProduct: Int64
            if isEnd0 {
                dotProduct = (a0 - b0).dotProduct(a0 - (a0 == a1 ? b1 : a1))
            } else {
                dotProduct = (b0 - a0).dotProduct(b0 - (b0 == a1 ? b1 : a1))
            }
            
            if dotProduct < 0 {
                return .sameEnd
            } else {
                return .overlap
            }
        } else if isCollinear {
            return .overlap
        } else if isEnd0 || isEnd1 {
            return .sameEnd
        }
        
        let notSame0 = a0b0a1 != a0b0b1
        let notSame1 = a1b1a0 != a1b1b0
        
        if notSame0 && notSame1 {
            return .pure
        } else {
            return .notCross
        }
    }
    
    
    static func randomSegments(range: Range<Int32>, length: Range<Int32>, count: Int) -> [RandomEdge] {
        var result = [RandomEdge]()
        result.reserveCapacity(count)
        
        let minSqrLength = Int64(length.lowerBound).sqr
        let maxSqrLength = Int64(length.upperBound).sqr
        let sqrLength = minSqrLength..<maxSqrLength
        
        for _ in 0..<count {
            var notFind = true
            var e = Self.randomEdge(range: range, sqrLengthRange: sqrLength)
            repeat {
                notFind = false
                for_:
                for ei in result {
                    switch Self.isCross(e0: e, e1: ei) {
                    case .pure, .overlap, .equal:
                        notFind = true
                        e = Self.randomEdge(range: range, sqrLengthRange: sqrLength)
                        break for_
                    default:
                        notFind = false
                    }
                }
            } while notFind
            
            result.append(e)
        }
        
        return result
    }
    
    static private func randomEdge(range: Range<Int32>, sqrLengthRange: Range<Int64>) -> RandomEdge {
        let x0 = Int32.random(in: range)
        let y0 = Int32.random(in: range)
        var x1 = Int32.random(in: range)
        var y1 = Int32.random(in: range)
        
        var edge = RandomEdge(a: Point(x0, y0), b: Point(x1, y1))
        
        var sqrLength = edge.sqrLength

        while sqrLengthRange.contains(sqrLength) {
            x1 = Int32.random(in: range)
            y1 = Int32.random(in: range)
            edge = RandomEdge(a: Point(x0, y0), b: Point(x1, y1))
            sqrLength = edge.sqrLength
        }
        
        return edge
    }
}

private extension Int64 {
    
    var sqr: Int64 {
        self * self
    }
}


private extension RandomEdge {
    
    var sqrLength: Int64 {
        let dx = Int64(a.x - b.x)
        let dy = Int64(a.y - b.y)
        
        return dx * dx + dy * dy
    }
    
}
