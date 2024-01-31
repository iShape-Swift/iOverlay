//
//  OverlayGraph+FillVector.swift
//
//
//  Created by Nail Sharipov on 30.01.2024.
//

import iFixFloat

// similar as for extract shapes but for vectors
public extension OverlayGraph {
    
    func extractVectors(overlayRule: OverlayRule) -> [VectorShape] {
        var visited = self.links.filter(overlayRule: overlayRule)
        
        var holes = [VectorPath]()
        var shapes = [VectorShape]()
        
        var j = 0
        while j < self.nodes.count {
            let i = self.findFirstLink(nodeIndex: j, visited: visited)
            guard i != .max else {
                j += 1
                continue
            }
            
            let isHole = overlayRule.isFillTop(fill: self.links[i].fill)
            var path = self.getPath(overlayRule: overlayRule, index: i, visited: &visited)
            path.validate(isHole: isHole)
            
            if isHole {
                holes.append(path)
            } else {
                shapes.append([path])
            }
        }
        
        shapes.join(holes: holes)
        
        return shapes
    }
    
    private func getPath(overlayRule: OverlayRule, index: Int, visited: inout [Bool]) -> VectorPath {
        var path = VectorPath()
        var next = index

        var link = links[index]
        
        var a = link.a
        var b = link.b

        // find a closed tour
        repeat {
            path.append(FillVector(fill: link.fill, a: a.point, b: b.point))
            let node = nodes[b.index]
            
            if node.indices.count == 2 {
                next = node.other(index: next)
            } else {
                let isFillTop = overlayRule.isFillTop(fill: link.fill)
                let isCW = OverlayGraph.isClockwise(a: a.point, b: b.point, isTopInside: isFillTop)
                next = self.findNearestLinkTo(target: a, center: b, ignore: next, inClockWise: isCW, visited: visited)
            }
            link = links[next]
            a = b
            b = link.other(b)
            visited[next] = true
        } while next != index
        
        visited[index] = true

        return path
    }
}

private extension Array where Element == VectorShape {
    
    mutating func join(holes: [VectorPath]) {
        guard !self.isEmpty && !holes.isEmpty else {
            return
        }
        
        if self.count == 1 {
            self[0].append(contentsOf: holes)
        } else {
            self.scanJoin(holes: holes)
        }
    }
    
    private mutating func scanJoin(holes: [VectorPath]) {
        var iPoints = [IdPoint]()
        iPoints.reserveCapacity(holes.count)
        for i in 0..<holes.count {
            iPoints.append(IdPoint(id: i, point: holes[i][0].a))
        }
        
        iPoints.sort(by: { $0.point.x < $1.point.x })

        let xMin = iPoints[0].point.x
        let xMax = iPoints[iPoints.count - 1].point.x
        var yMin: Int32 = .max
        var yMax: Int32 = .min
        
        var floors = [Floor]()
        for i in 0..<self.count {
            floors.append(contentsOf: self[i][0].floors(id: i, xMin: xMin, xMax: xMax, yMin: &yMin, yMax: &yMax))
        }
        
        floors.sort(by: { $0.seg.a.x < $1.seg.a.x })
        
        var scanList = XScanList(range: LineRange(min: yMin, max: yMax), count: floors.count)

        var holeShape = [Int](repeating: 0, count: holes.count)
        var holeCounter = [Int](repeating: 0, count: self.count)
        
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
        
        for shapeIndex in 0..<holeCounter.count {
            let capacity = holeCounter[shapeIndex]
            self[shapeIndex].reserveCapacity(capacity + 1)
        }

        for holeIndex in 0..<holes.count {
            let hole = holes[holeIndex]
            let shapeIndex = holeShape[holeIndex]
            self[shapeIndex].append(hole)
        }
    }

}

private extension VectorPath {
    
    // remove a short path and make cw if needed
    mutating func validate(isHole: Bool) {
        let isPositive = self.isPositive

        if isHole && isPositive || !isHole && isPositive {
            // for holes must be negative and for contour must be positive
            for i in 0..<self.count {
                self[i].reverse()
            }
        }
    }
    
    var isPositive: Bool {
        var area: Int64 = 0
        for v in self {
            area += v.a.crossProduct(v.b)
        }
        return area >= 0
    }
}
