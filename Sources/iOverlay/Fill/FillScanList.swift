//
//  FillScanList.swift
//
//
//  Created by Nail Sharipov on 07.12.2023.
//

import iShape
import iFixFloat

struct FillScanList {
    
    var space: LineSpace<UInt32>
    private let bottom: Int32
    private let delta: Int32
    
    init(segments: [Segment]) {
        var yMin = Int64.max
        var yMax = Int64.min
        for segment in segments {
            if segment.a.y > segment.b.y {
                yMin = min(segment.b.y, yMin)
                yMax = max(segment.a.y, yMax)
            } else {
                yMin = min(segment.a.y, yMin)
                yMax = max(segment.b.y, yMax)
            }
        }
        
        let maxLevel = Int(Double(segments.count).squareRoot()).logTwo
        
        bottom = Int32(yMin)
        space = LineSpace(level: maxLevel, range: LineRange(min: Int32(yMin), max: Int32(yMax)))
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
