//
//  ShapeEdge+Split.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iFixFloat
import iShape

extension Array where Element == ShapeEdge {
    
    func split() -> [Segment] {
        // at this moment array is sorted
        
        var list = SplitRangeList(edges: self)
        
        var scanList = LineSpace(edges: self)
        
        var needToFix = true
        
        var idsToRemove = [DualIndex]()
        
        var candidates = [LineContainer<VersionedIndex>]()
        
        while needToFix {
            scanList.clear()
            needToFix = false
            
            var eIndex = list.first()

            while eIndex.isNotNil {
                let thisEdge = list.edge(index: eIndex.index)

                if thisEdge.count.isEmpty {
                    eIndex = list.removeAndNext(index: eIndex.index)

                    continue
                }
                
                candidates.removeAll(keepingCapacity: true)
                scanList.allInRange(range: thisEdge.verticalRange, containers: &candidates)
                
                idsToRemove.removeAll(keepingCapacity: true)

                var newScanSegment: LineSegment<VersionedIndex>? = nil
                var isCross = false
                
            scan_loop:
                for item in candidates {
                    guard
                        let scanEdge = list.validateEdge(vIndex: item.id),
                        scanEdge.b.bitPack > thisEdge.a.bitPack
                    else {
                        idsToRemove.append(item.index)
                        continue
                    }

                    guard let cross = thisEdge.cross(scanEdge) else {
                        continue
                    }
                    
                    let vIndex = item.id
                    
                    isCross = true
                    
                    switch cross.type {
                    case .pure:
                        // if the two segments intersect at a point that isn't an end point of either segment...
                        
                        let x = cross.point

                        // divide both segments
                        
                        let thisLt = ShapeEdge.createAndValidate(a: thisEdge.a, b: x, count: thisEdge.count)
                        let thisRt = ShapeEdge.createAndValidate(a: x, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(thisLt.isLess(thisRt))
                        
                        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.a, b: x, count: scanEdge.count)
                        let scanRt = ShapeEdge.createAndValidate(a: x, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scanLt.isLess(scanRt))
                        
                        let newThisLeft = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisLt)
                        _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisRt)

                        let newScanLeft = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanLt)
                        _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanRt)

                        list.remove(index: eIndex.index)
                        list.remove(index: vIndex.index)

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x) || scanEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend
                        
                        eIndex = newThisLeft
                        
                        newScanSegment = .init(id: newScanLeft, range: scanLt.verticalRange)
                        
                        break scan_loop
                    case .end_b:
                        // scan edge end divide this edge into 2 parts
                        
                        let x = cross.point
                        
                        // divide this edge
                        
                        let thisLt = ShapeEdge.createAndValidate(a: thisEdge.a, b: x, count: thisEdge.count)
                        let thisRt = ShapeEdge.createAndValidate(a: x, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(thisLt.isLess(thisRt))
                        
                        _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisRt)
                        let newThisLeft = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisLt)

                        list.remove(index: eIndex.index)
                        
                        eIndex = newThisLeft
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend

                        break scan_loop
                    case .overlay_b:
                        // split this into 3 segments

                        let this0 = ShapeEdge(a: thisEdge.a, b: scanEdge.a, count: thisEdge.count)
                        let this1 = ShapeEdge(a: scanEdge.a, b: scanEdge.b, count: thisEdge.count)
                        let this2 = ShapeEdge(a: scanEdge.b, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(this0.isLess(this1))
                        assert(this1.isLess(this2))
                        
                        _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: this1)
                        _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: this2)
                        let newThis0 = list.addAndMerge(anchorIndex: eIndex.index, newEdge: this0)
                        
                        list.remove(index: eIndex.index)
                        
                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(scanEdge.a) || thisEdge.isNotSameLine(scanEdge.b)
                        needToFix = needToFix || isBend
                        
                        eIndex = newThis0
                        
                        break scan_loop
                    case .end_a:
                        // this edge end divide scan edge into 2 parts
                        
                        let x = cross.point

                        // divide scan edge
                        
                        let scanLt = ShapeEdge.createAndValidate(a: scanEdge.a, b: x, count: scanEdge.count)
                        let scanRt = ShapeEdge.createAndValidate(a: x, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scanLt.isLess(scanRt))
                        
                        let newScanLeft = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanLt)
                        _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanRt)

                        list.remove(index: vIndex.index)

                        // new point must be exactly on the same line
                        let isBend = scanEdge.isNotSameLine(x)
                        needToFix = needToFix || isBend
                        
                        // do not update eIndex
                        
                        newScanSegment = .init(id: newScanLeft, range: scanLt.verticalRange)
                        
                        break scan_loop
                    case .overlay_a:
                        // split scan into 3 segments
                        
                        let scan0 = ShapeEdge(a: scanEdge.a, b: thisEdge.a, count: scanEdge.count)
                        let scan1 = ShapeEdge(a: thisEdge.a, b: thisEdge.b, count: scanEdge.count)
                        let scan2 = ShapeEdge(a: thisEdge.b, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scan0.isLess(scan1))
                        assert(scan1.isLess(scan2))
                        
                        let newScan0 = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scan0)
                        _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scan1)
                        _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scan2)

                        list.remove(index: vIndex.index)

                        let isBend = scanEdge.isNotSameLine(thisEdge.a) || scanEdge.isNotSameLine(thisEdge.b)
                        needToFix = needToFix || isBend
                        
                        // do not update eIndex
                        
                        newScanSegment = .init(id: newScan0, range: scan0.verticalRange)
                        
                        break scan_loop
                    case .penetrate:
                        // penetrate each other
                        
                        let xThis = cross.point
                        let xScan = cross.second

                        // divide both segments
                        
                        let thisLt = ShapeEdge(a: thisEdge.a, b: xThis, count: thisEdge.count)
                        let thisRt = ShapeEdge(a: xThis, b: thisEdge.b, count: thisEdge.count)
                        
                        assert(thisLt.isLess(thisRt))
                        
                        let scanLt = ShapeEdge(a: scanEdge.a, b: xScan, count: scanEdge.count)
                        let scanRt = ShapeEdge(a: xScan, b: scanEdge.b, count: scanEdge.count)
                        
                        assert(scanLt.isLess(scanRt))
                        
                        let newScanLeft = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanLt)
                        _ = list.addAndMerge(anchorIndex: vIndex.index, newEdge: scanRt)
                        
                        _ = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisRt)
                        let newThisLeft = list.addAndMerge(anchorIndex: eIndex.index, newEdge: thisLt)

                        list.remove(index: eIndex.index)
                        list.remove(index: vIndex.index)

                        // new point must be exactly on the same line
                        let isBend = thisEdge.isNotSameLine(xThis) || scanEdge.isNotSameLine(xScan)
                        needToFix = needToFix || isBend
                        
                        eIndex = newThisLeft
                        
                        newScanSegment = .init(id: newScanLeft, range: scanLt.verticalRange)
                        
                        break scan_loop
                    }
                }
                
                if !idsToRemove.isEmpty {
                    scanList.remove(indices: &idsToRemove)
                    idsToRemove.removeAll(keepingCapacity: true)
                }
                
                if isCross {
                    if let scanSegment = newScanSegment {
                        scanList.insert(segment: scanSegment)
                    }
                } else {
                    scanList.insert(segment: LineSegment<VersionedIndex>(id: eIndex, range: thisEdge.verticalRange))
                    eIndex = list.next(index: eIndex.index)
                }
                
            } // while
            
        } // while
        
        return list.segments()
    }
    
}


private extension ShapeEdge {
    
    @inline(__always)
    func isNotSameLine(_ point: FixVec) -> Bool {
        Triangle.isNotLine(p0: a, p1: b, p2: point)
    }
    
    var verticalRange: LineRange {
        if a.y > b.y {
            return LineRange(min: Int32(b.y), max: Int32(a.y))
        } else {
            return LineRange(min: Int32(a.y), max: Int32(b.y))
        }
    }
    
    static func createAndValidate(a: FixVec, b: FixVec, count: ShapeCount) -> ShapeEdge {
        if a.bitPack <= b.bitPack {
            ShapeEdge(min: a, max: b, count: count)
        } else {
            ShapeEdge(min: b, max: a, count: count.invert())
        }
    }

}
