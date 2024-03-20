//
//  FillSolver.swift
//  
//
//  Created by Nail Sharipov on 05.03.2024.
//

import XCTest
import iFixFloat
@testable import iOverlay

struct FillSolver<Scan: ScanFillStore> {
    
    func run(scanList: Scan, items: [CountSegment], points: [Point]) -> [Int32] {
        var scanList = scanList

        var result = [Int32]()
        result.reserveCapacity(items.count)

        var i = 0
        for p in points {
            
            while i < items.count && items[i].xSegment.a.x <= p.x {
                if !items[i].xSegment.isVertical && items[i].xSegment.b.x > p.x {
                    scanList.insert(segment: items[i], stop: p.x)
                }
                i += 1
            }
            
            let index = scanList.findUnder(point: p, stop: p.x)?.count.subj ?? .min
            result.append(index)
        }
        
        return result
    }
    
}
