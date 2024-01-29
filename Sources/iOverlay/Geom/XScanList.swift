//
//  XScanList.swift
//  
//
//  Created by Nail Sharipov on 26.01.2024.
//

import iShape
import iFixFloat

struct XScanList {
    
    var space: ScanSpace<Int, Int32>

    private let delta: Int32
    
    init(range: LineRange, count: Int) {
        space = ScanSpace(range: range, count: count)
        delta = Int32(1 << space.indexer.scale)
    }
    
    func iteratorToBottom(start: Int32) -> LineRange {
        let range = self.space.indexer.range
        let top = min(range.max, start)
        let minY = max(range.min, top - self.delta)
        return LineRange(min: minY, max: top)
    }
    
    func next(range: LineRange) -> LineRange {
        let bottom = self.space.indexer.range.min
        guard range.min > bottom else {
            return LineRange(min: .min, max: .min)
        }
        let radius = (range.max - range.min) << 1
        let minY = max(range.min - radius, bottom)
        return LineRange(min: minY, max: range.min)
    }
}
