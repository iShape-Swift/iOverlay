//
//  Array+Split.swift
//  
//
//  Created by Nail Sharipov on 13.07.2023.
//

import iFixFloat
import iShape

struct SplitResult {
    let segments: [Segment]
    let newVerts: [IndexPoint]
}

extension Array where Element == Segment {
    
    func split(pointsCount: Int) -> SplitResult {
        var segments = self.sorted(by: { $0.a.point.bitPack < $1.a.point.bitPack })
        
        var scanList = ScanList()
        
        var segIndex = 0
        
        var xStore = IndexPointStore(count: pointsCount)
    mainLoop:
        while segIndex < segments.count {
            let thisSeg = segments[segIndex]
            
            let scanPos = thisSeg.a.point.bitPack

            scanList.removeAllFromLeft(scanPos)
            
            // try to cross with the scan list
            for scanIndex in 0..<scanList.segments.count {
                
                let scanSeg = scanList.segments[scanIndex]
                
                let cross = thisSeg.cross(scanSeg)
                
                switch cross.type {
                case .not_cross, .common_end:
                    break
                case .pure:
                    let x = cross.point
                    let ix = xStore.getIndex(x)
                    
                    // devide segments

                    let thisId = thisSeg.id
                    let nextId = segments.count
                    
                    let scanId = scanSeg.id
                    
                    // scan index in segments array
                    let sIndex = segments.findById(scanId, value: scanSeg.a.point.bitPack)
                    
                    let thisLt = Segment(id: thisId, isDirect: thisSeg.isDirect, a: thisSeg.a, b: ix)
                    let thisRt = Segment(id: nextId, isDirect: thisSeg.isDirect, a: ix, b: thisSeg.b)
                    
                    let scanLt = Segment(id: scanId, isDirect: scanSeg.isDirect, a: scanSeg.a, b: ix)
                    let scanRt = Segment(id: nextId + 1, isDirect: scanSeg.isDirect, a: ix, b: scanSeg.b)
                    
                    segments[segIndex] = thisLt
                    segments.insertSegmentSortedByA(thisRt)
                    
                    segments[sIndex] = scanLt
                    segments.insertSegmentSortedByA(scanRt)

                    // new point must be exactly on the same line
                    let isBend = Triangle.isNotLine(p0: thisSeg.a.point, p1: thisSeg.b.point, p2: x) || Triangle.isNotLine(p0: scanSeg.a.point, p1: scanSeg.b.point, p2: x)
                    
                    if isBend {
                        // changed segments could overlap with previous segments
                        
                        assert(scanLt.a.point.bitPack < thisLt.a.point.bitPack)
                        
                        // roll back before scanLt.a
                        let newScanPos = scanLt.a.point.bitPack - 1
                        segIndex = segments.findIndexByA(newScanPos)

                        // add all segments which can overlap newScanPos
                        scanList.fill(segments, withFirst: segIndex, overlay: newScanPos)
                        
                        debugPrint("roolback to index: \(segIndex)")
                    } else {
                        // replace current with left part
                        scanList.segments[scanIndex] = scanLt
                    }
                    
                    continue mainLoop
                case .end_b:
                    let x = cross.point
                    let ix = x == scanSeg.a.point ? scanSeg.a : scanSeg.b

                    // devide this segment

                    let thisId = thisSeg.id
                    let nextId = segments.count
                    
                    let thisLt = Segment(id: thisId, isDirect: thisSeg.isDirect, a: thisSeg.a, b: ix)
                    let thisRt = Segment(id: nextId, isDirect: thisSeg.isDirect, a: ix, b: thisSeg.b)

                    segments[segIndex] = thisLt
                    segments.insertSegmentSortedByA(thisRt)

                    // new point must be exactly on the same line
                    let isBend = Triangle.isNotLine(p0: thisSeg.a.point, p1: thisSeg.b.point, p2: x)
                    
                    if isBend {
                        // changed segments could overlap with previous segments

                        // roll back before thisLt.a
                        let newScanPos = thisLt.a.point.bitPack - 1
                        segIndex = segments.findIndexByA(newScanPos)

                        // add all segments which can overlap newScanPos
                        scanList.fill(segments, withFirst: segIndex, overlay: newScanPos)
                        
                        debugPrint("roolback to index: \(segIndex)")
                    }

                    continue mainLoop
                case .end_a:
                    let x = cross.point
                    let ix = x == thisSeg.a.point ? thisSeg.a : thisSeg.b

                    // devide scan segment

                    let scanId = scanSeg.id
                    let nextId = segments.count
                    
                    // scan index in segments array
                    let sIndex = segments.findById(scanId, value: scanSeg.a.point.bitPack)
                    
                    let scanLt = Segment(id: scanId, isDirect: scanSeg.isDirect, a: scanSeg.a, b: ix)
                    let scanRt = Segment(id: nextId, isDirect: scanSeg.isDirect, a: ix, b: scanSeg.b)
                    
                    segments[sIndex] = scanLt
                    segments.insertSegmentSortedByA(scanRt)

                    // new point must be exactly on the same line
                    let isBend = Triangle.isNotLine(p0: scanSeg.a.point, p1: scanSeg.b.point, p2: x)
                    
                    if isBend {
                        // changed segments could overlap with previous segments
                        
                        // roll back before scanLt.a
                        let newScanPos = scanLt.a.point.bitPack - 1
                        segIndex = segments.findIndexByA(newScanPos)

                        // add all segments which can overlap newScanPos
                        scanList.fill(segments, withFirst: segIndex, overlay: newScanPos)
                        
                        debugPrint("roolback to index: \(segIndex)")
                    } else {
                        // replace current with left part
                        scanList.segments[scanIndex] = scanLt
                    }
                    
                    continue mainLoop
                }
                
            } // for scanList
            
            // no intersections, add to scan
            scanList.add(thisSeg)
            segIndex += 1
            
        } // while queue

        return SplitResult(segments: segments, newVerts: xStore.points)
    }
    
}

private struct ScanList {
    
    var segments: [Segment]
    private var minEnd: Int64
    
    init() {
        self.segments = [Segment]()
        self.segments.reserveCapacity(8)
        self.minEnd = .max
    }
    
    mutating func add(_ segment: Segment) {
        segments.append(segment)
        minEnd = min(minEnd, segment.b.point.bitPack)
    }
    
    mutating func removeAllFromLeft(_ pos: Int64) {
        guard minEnd <= pos else { return } // if segments is empty then minEnd === .max
        var minPos = Int64.max
        var i = 0
        var j = segments.count - 1
        var n = 0
        while i <= j {
            let seg = segments[i]
            let bPos = seg.b.point.bitPack
            if bPos <= pos {
                segments[i] = segments[j]
                j -= 1
                n += 1
            } else {
                i += 1
                minPos = min(minPos, bPos)
            }
        }
        minEnd = minPos
        segments.removeLast(n)
    }

    mutating func fill(_ list: [Segment], withFirst count: Int, overlay pos: Int64) {
        segments.removeAll(keepingCapacity: true)
        self.minEnd = .max
        for i in 0..<count {
            let seg = list[i]
            let bPos = seg.b.point.bitPack
            if bPos > pos {
                segments.append(seg)
                minEnd = min(minEnd, bPos)
            }
        }
    }
}

private struct IndexPointStore {
    
    private var map: [FixVec: Int]
    private (set) var count: Int
    
    var points: [IndexPoint] {
        var result = [IndexPoint]()
        result.reserveCapacity(map.count)
        for item in map {
            result.append(IndexPoint(index: item.value, point: item.key))
        }
        return result
    }
    
    mutating func getIndex(_ point: FixVec) -> IndexPoint {
        if let i = map[point] {
            return IndexPoint(index: i, point: point)
        } else {
            map[point] = count
            let ip = IndexPoint(index: count, point: point)
            count += 1
            return ip
        }
    }
    
    init(count: Int) {
        self.count = count
        map = [:]
    }
    
}
