//
//  SegmentScanList.swift
//  
//
//  Created by Nail Sharipov on 21.07.2023.
//

import iShape
import iFixFloat

struct SegmentScanList {
    
    private (set) var segments: [Segment]
    private var minEnd: Int64
    private var thisPosChainCount: Int
    private var thisPos: Int
    
    init() {
        self.segments = [Segment]()
        self.segments.reserveCapacity(8)
        self.minEnd = .max
        self.thisPosChainCount = 0
        self.thisPos = 0
    }
    
    mutating func clear() {
        self.minEnd = .max
        self.segments.removeAll(keepingCapacity: true)
    }
    
    mutating func add(_ segment: Segment) -> FillMask {
        let a = segment.a
        var n = 0
        
        var i = 0
        var ib = -1
        var ia = -1
        var sameXArray = [Int]()
        sameXArray.reserveCapacity(4)
        
        while i < segments.count {
            let s = segments[i]
            if s.a.x == a.x {
                if s.a.y < a.y && sameXArray.contains(<#T##other: Collection##Collection#>) {
                    
                }
                
            } else {
                
                
            }
        }
        
        
        segments.append(edge)
        minEnd = min(minEnd, edge.b.bitPack)
    }
    
    mutating func removeSegmentsEndingBeforePosition(_ point: FixVec) {
        let pos = point.bitPack
        
        if thisPos < point.x {
            thisPosChainCount = 0
        }
        
        guard minEnd <= pos else { return } // if segments is empty then minEnd === .max
        var minPos = Int64.max
        var i = 0
        var j = segments.count - 1
        var n = 0
        while i <= j {
            let edge = segments[i]
            let bPos = edge.b.bitPack
            if bPos <= pos {
                segments[i] = segments[j]
                j -= 1
                n += 1
            } else {
                i += 1
                minPos = min(minPos, bPos)
            }
        }
        minEnd = minPos
        segments.removeLast(n)
    }
    
}
