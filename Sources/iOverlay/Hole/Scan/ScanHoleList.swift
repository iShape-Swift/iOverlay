//
//  ScanHoleList.swift
//
//
//  Created by Nail Sharipov on 26.03.2024.
//

import iFixFloat

struct ScanHoleList: ScanHoleStore {

    private var buffer: [IdSegment]

    init(count: Int) {
        self.buffer = [IdSegment]()
        self.buffer.reserveCapacity(count.logSqrt)
    }
    
    @inline(__always)
    mutating func insert(segment: IdSegment, stop: Int32) {
        buffer.append(segment)
    }
    
    mutating func underAndNearest(point p: Point, stop: Int32) -> Int {
        var i = 0
        var result: IdSegment? = nil
        while i < self.buffer.count {
            if self.buffer[i].xSegment.b.x <= stop {
                self.buffer.swapRemove(i)
            } else {
                let segment = self.buffer[i].xSegment
                if segment.isUnder(point: p) {
                    if let bestSeg = result?.xSegment {
                        if bestSeg.isUnder(segment: segment) {
                            result = self.buffer[i]
                        }
                    } else {
                        result = self.buffer[i]
                    }
                }
                
                i += 1
            }
        }
        
        return result?.id ?? 0
    }
}