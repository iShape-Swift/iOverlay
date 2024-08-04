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
    public let xSegment: XSegment
    var count: ShapeCount
    
    public init(a: Point, b: Point, count: ShapeCount) {
        if a < b {
            xSegment = XSegment(a: a, b: b)
        } else {
            xSegment = XSegment(a: b, b: a)
        }
        self.count = count
    }

    init(xSegment: XSegment, count: ShapeCount) {
        self.xSegment = xSegment
        self.count = count
    }
    
    static func createAndValidate(a: Point, b: Point, count: ShapeCount) -> ShapeEdge {
        if a < b {
            ShapeEdge(xSegment: XSegment(a: a, b: b), count: count)
        } else {
            ShapeEdge(xSegment: XSegment(a: b, b: a), count: count.invert())
        }
    }
}

extension ShapeEdge: Equatable {
    
    @inline(__always)
    public static func == (lhs: ShapeEdge, rhs: ShapeEdge) -> Bool {
        lhs.xSegment == rhs.xSegment
    }
}

extension ShapeEdge: Comparable {
    @inline(__always)
    public static func < (lhs: ShapeEdge, rhs: ShapeEdge) -> Bool {
        lhs.xSegment < rhs.xSegment
    }
}

extension Array where Element == ShapeEdge {
    mutating func mergeIfNeeded() {
        let n = self.count
        guard n > 1 else {
            return
        }

        var i = 1
        while i < n {
            if self[i - 1].xSegment == self[i].xSegment {
                break
            }
            i += 1
        }

        guard i != n else {
            return
        }

        var j = i - 1
        var prev = self[j]

        while i < n {
            if prev.xSegment == self[i].xSegment {
                prev.count = prev.count.add(self[i].count)
            } else {
                if !prev.count.isEmpty {
                    self[j] = prev
                    j += 1
                }
                prev = self[i]
            }
            i += 1
        }
        
        if !prev.count.isEmpty {
            self[j] = prev
            j += 1
        }

        if j < n {
            self.removeLast(n - j)
        }
    }
}
