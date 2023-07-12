//
//  File.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public extension Array where Element == FixVec {
    
    func segGraph() -> SegmentGraph {
        let clean = self.removedDegenerates()
        guard clean.count > 2 else {
            return SegmentGraph(segments: [])
        }
        
        var segs = clean.createSegments()
        
        var count = 0
        
        var isModified = true
        repeat {
            let result = segs.cross()
            segs = result.segs
            isModified = result.isAnyBend
            count += 1
        } while isModified
        
        debugPrint("divide count: \(count)")

        return SegmentGraph(segments: segs)
    }
    
    private func createSegments() -> [Segment] {
        var segs = [Segment](repeating: .zero, count: count)
        var a = self[count - 1]
        for i in 0..<count {
            let b = self[i]
            segs[i] = Segment(a: a, b: b)
            a = b
        }
        return segs
    }
}

private struct SegmentCrossResult {
    let isAnyBend: Bool
    let segs: [Segment]
}

private extension Array where Element == Segment {
    
    func cross() -> SegmentCrossResult {
        var queue = self.sorted(by: { $0.a.bitPack > $1.a.bitPack })
        
        var scanList = [Segment]()
        scanList.reserveCapacity(8)
        
        var result = [Segment]()
        result.reserveCapacity(count)
        
        var isAnyBend = false
        
    queueLoop:
        while !queue.isEmpty {
            
            // get segment with the smallest a
            let thisSeg = queue.removeLast()
            
            let completed = scanList.allB(before: thisSeg.a.bitPack)
            if completed > 0 {
                let i0 = scanList.count - completed
                let i1 = scanList.count
                result.append(contentsOf: scanList[i0..<i1])
                scanList.removeLast(completed)
            }
            
            // try to cross with the scan list
            for scanIndex in 0..<scanList.count {
                
                let scanSeg = scanList[scanIndex]
                
                let cross = thisSeg.cross(scanSeg)
                
                switch cross.type {
                case .not_cross, .common_end:
                    break
                case .pure:
                    let x = cross.point
                    
                    // devide segments
                    
                    isAnyBend = isAnyBend || Triangle.isNotLine(p0: thisSeg.a, p1: thisSeg.b, p2: x)
                    
                    let thisLt = Segment(isDirect: thisSeg.isDirect, a: thisSeg.a, b: x)
                    let thisRt = Segment(isDirect: thisSeg.isDirect, a: x, b: thisSeg.b)
                    
                    isAnyBend = isAnyBend || Triangle.isNotLine(p0: scanSeg.a, p1: scanSeg.b, p2: x)
                    
                    let scanLt = Segment(isDirect: scanSeg.isDirect, a: scanSeg.a, b: x)
                    let scanRt = Segment(isDirect: scanSeg.isDirect, a: x, b: scanSeg.b)

                    queue.addA(thisLt)
                    queue.addA(thisRt)
                    queue.addA(scanRt)

                    scanList[scanIndex] = scanLt
                    
                    continue queueLoop
                case .end_b:
                    let x = cross.point

                    // devide this segment
                    
                    isAnyBend = isAnyBend || Triangle.isNotLine(p0: thisSeg.a, p1: thisSeg.b, p2: x)
                    
                    let thisLt = Segment(isDirect: thisSeg.isDirect, a: thisSeg.a, b: x)
                    let thisRt = Segment(isDirect: thisSeg.isDirect, a: x, b: thisSeg.b)

                    queue.addA(thisLt)
                    queue.addA(thisRt)

                    continue queueLoop
                case .end_a:
                    let x = cross.point

                    // devide scan segment
                    
                    isAnyBend = isAnyBend || Triangle.isNotLine(p0: scanSeg.a, p1: scanSeg.b, p2: x)
                    
                    let scanLt = Segment(isDirect: scanSeg.isDirect, a: scanSeg.a, b: x)
                    let scanRt = Segment(isDirect: scanSeg.isDirect, a: x, b: scanSeg.b)

                    queue.addA(thisSeg) // put it back!
                    queue.addA(scanRt)
                    
                    scanList[scanIndex] = scanLt
                    
                    continue queueLoop
                }
                
            } // for scanList
            
            // no intersections, add to scan
            scanList.addA(thisSeg)
        } // while queue
        
        
        result.append(contentsOf: scanList)
        
        return SegmentCrossResult(isAnyBend: isAnyBend, segs: result)
    }
    
}
