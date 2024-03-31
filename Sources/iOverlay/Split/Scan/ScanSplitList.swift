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
        buffer = [VersionSegment]()
        buffer.reserveCapacity(count.log2Sqrt)
    }
    
    mutating func intersectAndRemoveOther(this: XSegment) -> CrossSegment? {
        // normally scan list contain segments before this segment,
        // but sometimes after rollback it can contain segments behind this segment
        // in that case we remove segments (they will be added automatically later)

        var i = 0
        let scanPos = this.a
        while i < buffer.count {
            let scan = self.buffer[i]
            
            let isValid = ScanCrossSolver.isValid(scan: scan.xSegment, this: this)
            
            if !isValid {
                self.buffer.swapRemove(i)
                continue
            }
            
            // order is important! thix x scan
            if let cross = ScanCrossSolver.cross(target: this, other: scan.xSegment) {
                self.buffer.swapRemove(i)
                return CrossSegment(other: scan.vIndex, cross: cross)
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
