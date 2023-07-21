//
//  SelfEdge+Split.swift
//  
//
//  Created by Nail Sharipov on 20.07.2023.
//

import iFixFloat
import iShape

extension Array where Element == SelfEdge {
    
    mutating func split() {
        var scanList = ScanList()
        
        var eIndex = 0
        
        // Begin processing all the segments in the array.
    mainLoop:
        while eIndex < self.count {
            let thisEdge = self[eIndex]
            
            let scanPos = thisEdge.a.bitPack

            scanList.removeSegmentsEndingBeforePosition(scanPos)
            
            let eThis = thisEdge.edge
            
            // Try to intersect the current segment with all the segments in the scan list.
            for scanIndex in 0..<scanList.edges.count {
                
                let eScan = scanList.edges[scanIndex]
                let cross = eThis.cross(eScan)
                
                switch cross.type {
                case .not_cross, .common_end:
                    break
                case .pure:
                    // If the two segments intersect at a point that isn't an end point of either segment...
                    
                    let x = cross.point
                    
                    let sIndex = self.findEdgeIndex(eScan)
                    let scanEdge = self[sIndex]
                    
                    if eIndex < sIndex {
                        self.remove(at: sIndex)
                        self.remove(at: eIndex)
                    } else {
                        self.remove(at: eIndex)
                        self.remove(at: sIndex)
                    }
                    
                    // devide both segments
                    
                    let thisLt = SelfEdge(a: thisEdge.a, b: x, n: thisEdge.n)
                    let thisRt = SelfEdge(a: x, b: thisEdge.b, n: thisEdge.n)
                    
                    let scanLt = SelfEdge(a: scanEdge.a, b: x, n: scanEdge.n)
                    let scanRt = SelfEdge(a: x, b: scanEdge.b, n: scanEdge.n)
                    
                    _ = self.addAndMerge(scanLt)
                    _ = self.addAndMerge(scanRt)
                    _ = self.addAndMerge(thisRt)
                    eIndex = self.addAndMerge(thisLt)

                    // new point must be exactly on the same line
                    let isBend = thisEdge.isNotSameLine(x) || scanEdge.isNotSameLine(x)
                    
                    // if the new intersection point causes the segments to be non-collinear...
                    if isBend {
                        
                        assert(scanLt.a.bitPack < thisLt.a.bitPack)
                        
                        // roll back before scanLt.a
                        let newScanPos = scanLt.a.bitPack - 1
                        eIndex = self.findAnyIndexByStart(newScanPos)

                        // add all segments which can overlap newScanPos
                        scanList.fill(self, withFirst: eIndex, overlay: newScanPos)
                        
                        debugPrint("roolback to index: \(eIndex)")
                    } else {
                        // replace current with left part
                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                        scanList.removeAllLater(edge: thisLt.edge)
                    }
                    
                    assert(self.isAsscending())

                    continue mainLoop
                case .end_b:
                    // if the intersection point is at the end of the current edge...
                    
                    let x = cross.point
                    
                    // devide this edge
                    
                    self.remove(at: eIndex)
                    
                    let thisLt = SelfEdge(a: thisEdge.a, b: x, n: thisEdge.n)
                    let thisRt = SelfEdge(a: x, b: thisEdge.b, n: thisEdge.n)
                    
                    _ = self.addAndMerge(thisRt)
                    eIndex = self.addAndMerge(thisLt)

                    // new point must be exactly on the same line
                    let isBend = thisEdge.isNotSameLine(x)
                    
                    // if the new intersection point causes the edges to be non-collinear...
                    if isBend {

                        // roll back before thisLt.a
                        let newScanPos = thisLt.a.bitPack - 1
                        eIndex = self.findAnyIndexByStart(newScanPos)

                        // add all segments which can overlap newScanPos
                        scanList.fill(self, withFirst: eIndex, overlay: newScanPos)
                        
                        debugPrint("roolback to index: \(eIndex)")
                    } else {
                        scanList.removeAllLater(edge: thisLt.edge)
                    }

                    assert(self.isAsscending())
                    
                    continue mainLoop
                case .end_a:
                    // if the intersection point is at the end of the segment from the scan list...
                    
                    let x = cross.point

                    // devide scan segment
                    
                    let sIndex = self.findEdgeIndex(eScan)
                    let scanEdge = self[sIndex]
                    self.remove(at: sIndex)
                    
                    let scanLt = SelfEdge(a: scanEdge.a, b: x, n: scanEdge.n)
                    let scanRt = SelfEdge(a: x, b: scanEdge.b, n: scanEdge.n)

                    _ = self.addAndMerge(scanLt)
                    _ = self.addAndMerge(scanRt)

                    eIndex = self.findEdgeIndex(eThis)

                    // new point must be exactly on the same line
                    let isBend = scanEdge.isNotSameLine(x)
                    
                    // if the new intersection point causes the edges to be non-collinear...
                    if isBend {
                        
                        // roll back before scanLt.a
                        let newScanPos = scanLt.a.bitPack - 1
                        eIndex = self.findAnyIndexByStart(newScanPos)

                        // add all segments which can overlap newScanPos
                        scanList.fill(self, withFirst: eIndex, overlay: newScanPos)
                        
                        debugPrint("roolback to index: \(eIndex)")
                    } else {
                        // replace current with left part
                        scanList.replace(oldIndex: scanIndex, newEdge: scanLt)
                    }
                    
                    assert(self.isAsscending())
                    
                    continue mainLoop
                }
                
            } // for scanList
            
            // no intersections, add to scan
            scanList.add(thisEdge.edge)
            eIndex += 1
            
        } // while queue
        
        
#if DEBUG
        assert(Set(self).count == count)
#endif
    }
    
}

private struct ScanList {
    
    var edges: [FixEdge]
    private var minEnd: Int64
    
    init() {
        self.edges = [FixEdge]()
        self.edges.reserveCapacity(8)
        self.minEnd = .max
    }
    
    mutating func add(_ edge: FixEdge) {
        edges.append(edge)
        minEnd = min(minEnd, edge.e1.bitPack)
    }
    
    mutating func removeSegmentsEndingBeforePosition(_ pos: Int64) {
        guard minEnd <= pos else { return } // if segments is empty then minEnd === .max
        var minPos = Int64.max
        var i = 0
        var j = edges.count - 1
        var n = 0
        while i <= j {
            let edge = edges[i]
            let bPos = edge.e1.bitPack
            if bPos <= pos {
                edges[i] = edges[j]
                j -= 1
                n += 1
            } else {
                i += 1
                minPos = min(minPos, bPos)
            }
        }
        minEnd = minPos
        edges.removeLast(n)
    }

    mutating func fill(_ list: [SelfEdge], withFirst count: Int, overlay pos: Int64) {
        edges.removeAll(keepingCapacity: true)
        self.minEnd = .max
        for i in 0..<count {
            let e = list[i]
            let bPos = e.b.bitPack
            if bPos > pos {
                edges.append(e.edge)
                minEnd = min(minEnd, bPos)
            }
        }
    }
    
    mutating func replace(oldIndex: Int, newEdge: SelfEdge) {
        if self.isContain(newEdge.edge) {
            // newEdge is exist, but we still must remove old edge
            edges.remove(at: oldIndex)
        } else {
            // newEdge is not exist, so we only update old edge
            edges[oldIndex] = newEdge.edge
        }
    }

    mutating func removeAllLater(edge: FixEdge) {
        var i = 0
        while i < edges.count {
            let e = edges[i]
            
            if edge.isLess(e) {
                edges.remove(at: i)
            } else {
                i += 1
            }
        }
    }
    
    private func isContain(_ edge: FixEdge) -> Bool {
        for e in edges where e.isEqual(edge) {
            return true
        }
        return false
    }
    
}

private extension SelfEdge {
    
    func isNotSameLine(_ point: FixVec) -> Bool {
        Triangle.isNotLine(p0: a, p1: b, p2: point)
    }
    
}


private extension FixEdge {
    
    func isLess(_ other: FixEdge) -> Bool {
        let a0 = e0.bitPack
        let a1 = other.e0.bitPack
        if a0 != a1 {
            return a0 < a1
        } else {
            let b0 = e1.bitPack
            let b1 = other.e1.bitPack
            
            return b0 < b1
        }
    }
    
    func isEqual(_ other: FixEdge) -> Bool {
        let a0 = e0.bitPack
        let a1 = other.e0.bitPack
        let b0 = e1.bitPack
        let b1 = other.e1.bitPack
        
        return a0 == a1 && b0 == b1
    }
}
