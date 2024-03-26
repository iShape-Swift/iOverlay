//
//  ScanFillList.swift
//  
//
//  Created by Nail Sharipov on 05.03.2024.
//

import iFixFloat

struct ScanFillList: ScanFillStore {

    private var buffer: [CountSegment]

    @inline(__always)
    init(count: Int) {
        self.buffer = [CountSegment]()
        let capacity = Int(Double(count << 1).squareRoot())
        self.buffer.reserveCapacity(capacity)
    }
    
    @inline(__always)
    mutating func insert(segment: CountSegment, stop: Int32) {
        buffer.append(segment)
    }
    
    mutating func underAndNearest(point p: Point, stop: Int32) -> ShapeCount? {
        var i = 0
        var result: CountSegment? = nil
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
        
        return result?.count
    }
}
