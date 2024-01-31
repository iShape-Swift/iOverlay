//
//  HolesSolver.swift
//
//
//  Created by Nail Sharipov on 31.01.2024.
//

import iFixFloat

struct HolesSolution {
    let holeShape: [Int]
    let holeCounter: [Int]
}

struct HolesSolver {

    static func solve(shapeCount: Int, yRange: LineRange, iPoints: [IdPoint], floors: [Floor]) -> HolesSolution {
        let holeCount = iPoints.count
        
        var scanList = XScanList(range: yRange, count: floors.count)

        var holeShape = [Int](repeating: 0, count: holeCount)
        var holeCounter = [Int](repeating: 0, count: shapeCount)
        
        var candidates = [Int]()
       
        var i = 0
        var j = 0

        while i < iPoints.count {
            let x = iPoints[i].point.x
            
            while j < floors.count && floors[j].seg.a.x < x {
                let floor = floors[j]
                if floor.seg.b.x > x {
                    scanList.space.insert(segment: ScanSegment(
                        id: j,
                        range: floor.seg.yRange,
                        stop: floor.seg.b.x
                    ))
                }
                j += 1
            }
        
            while i < iPoints.count && iPoints[i].point.x == x {
                
                let p = iPoints[i].point
                
                // find nearest scan segment for y
                var iterator = scanList.iteratorToBottom(start: p.y)
                var bestFloor: Floor?

                while iterator.min != .min {
                    scanList.space.idsInRange(range: iterator, stop: x, ids: &candidates)
                    if !candidates.isEmpty {
                        for floorIndex in candidates {
                            let floor = floors[floorIndex]
                            if floor.seg.isUnder(point: p) {
                                if let bestSeg = bestFloor?.seg {
                                    if bestSeg.isUnder(segment: floor.seg) {
                                        bestFloor = floor
                                    }
                                } else {
                                    bestFloor = floor
                                }
                            }
                        }
                        candidates.removeAll(keepingCapacity: true)
                    }
                    
                    if let bestSeg = bestFloor?.seg, bestSeg.isAbove(point: Point(x: x, y: iterator.min)) {
                        break
                    }

                    iterator = scanList.next(range: iterator)
                }
                
                assert(bestFloor != nil)
                let shapeIndex = bestFloor?.id ?? 0
                let holeIndex = iPoints[i].id
                
                holeShape[holeIndex] = shapeIndex
                holeCounter[shapeIndex] += 1
                
                i += 1
            }
        }
        
        return HolesSolution(holeShape: holeShape, holeCounter: holeCounter)
    }
    
}
