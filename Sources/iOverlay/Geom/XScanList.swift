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

    private let bottom: Int32
    private let delta: Int32
    
    init(range: LineRange, count: Int) {
        bottom = range.min
        space = ScanSpace(range: range, count: count)
        delta = Int32(1 << space.indexer.scale)
    }
    
    func iteratorToBottom(start: Int32) -> LineRange {
        let minY = max(start - delta, bottom)
        return LineRange(min: minY, max: start)
    }
    
    func next(range: LineRange) -> LineRange {
        guard range.min > bottom else {
            return LineRange(min: .min, max: .min)
        }
        let radius = (range.max - range.min) << 1
        let minY = max(range.min - radius, bottom)
        return LineRange(min: minY, max: range.min)
    }
}