//
//  ScanSplitList.swift
//
//
//  Created by Nail Sharipov on 20.03.2024.
//

import iFixFloat

struct ScanSplitList: ScanSplitStore {
    
    private var buffer: [VersionSegment]
    
    @inline(__always)
    init(count: Int) {
        let capacity = Int(Double(count << 1).squareRoot())
        buffer = [VersionSegment]()
        buffer.reserveCapacity(capacity)
    }
    
    mutating func intersect(this: XSegment) -> CrossSegment? {
        var i = 0
        let scanPos = this.a
        while i < buffer.count {
            let scan = self.buffer[i]
            if Point.xLineCompare(a: scan.xSegment.b, b: scanPos) {
                self.buffer.swapRemove(i)
                continue
            }
            
            // order is important! thix x scan
            if let cross = this.cross(scan.xSegment) {
                self.buffer.swapRemove(i)
                return CrossSegment(index: scan.vIndex, cross: cross)
            }
            
            i += 1
        }
        
        return nil
    }
    
    @inline(__always)
    mutating func insert(segment: VersionSegment) {
        buffer.append(segment)
    }
    
    @inline(__always)
    mutating func clear() {
        buffer.removeAll(keepingCapacity: true)
    }
}
