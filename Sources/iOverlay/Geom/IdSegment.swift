//
//  IdSegment.swift
//
//
//  Created by Nail Sharipov on 25.01.2024.
//

import iFixFloat
import iShape

struct IdSegment {
    let id: Int
    let xSegment: XSegment
    
    init(id: Int, a: Point, b: Point) {
        self.id = id
        self.xSegment = XSegment(a: a, b: b)
    }
    
    init(id: Int, xSegment: XSegment) {
        self.id = id
        self.xSegment = xSegment
    }
}

extension IdSegment: Comparable {
    static func < (lhs: IdSegment, rhs: IdSegment) -> Bool {
        lhs.xSegment < rhs.xSegment
    }
}

extension IdSegment: Equatable {
    public static func == (lhs: IdSegment, rhs: IdSegment) -> Bool {
        lhs.xSegment == rhs.xSegment
    }
}

extension FixPath {
    
    func idSegments(id: Int, xMin: Int32, xMax: Int32) -> [IdSegment] {
        var list = [IdSegment]()
        let n = self.count
        list.reserveCapacity(3 * n / 4)
        
        var b = self[n - 1]
        for a in self {
            if a.x < b.x && xMin < b.x && a.x <= xMax {
                list.append(IdSegment(id: id, a: Point(a), b: Point(b)))
            }
            b = a
        }
        return list
    }
}

extension VectorPath {
    
    func idSegments(id: Int, xMin: Int32, xMax: Int32) -> [IdSegment] {
        var list = [IdSegment]()
        let n = self.count
        list.reserveCapacity(3 * n / 4)
        
        for vec in self {
            if vec.a.x < vec.b.x && xMin < vec.b.x && vec.a.x <= xMax {
                list.append(IdSegment(id: id, a: Point(vec.a), b: Point(vec.b)))
            }
        }
        return list
    }
}
