//
//  ScanSplitList.swift
//
//
//  Created by Nail Sharipov on 20.03.2024.
//

struct ScanSplitList: ScanSplitStore {
    
    private var buffer: [VersionSegment]
    
    init(count: Int) {
        let capacity = Int(Double(count << 1).squareRoot())
        buffer = [VersionSegment]()
        buffer.reserveCapacity(capacity)
    }
    
    mutating func intersect(this: XSegment, scanPos: Int32) -> CrossSegment? {
        var i = 0
        while i < buffer.count {
            let scan = self.buffer[i]
            if scan.xSegment.b.x <= scanPos {
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
    
    mutating func insert(segment: VersionSegment) {
        buffer.append(segment)
    }
    
    mutating func clear() {
        buffer.removeAll(keepingCapacity: true)
    }
}
