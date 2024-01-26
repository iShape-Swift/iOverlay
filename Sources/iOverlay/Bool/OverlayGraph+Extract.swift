//
//  OverlayGraph+Extract.swift
//  
//
//  Created by Nail Sharipov on 08.08.2023.
//

import iShape
import iFixFloat

private struct Contour {
    let isHole: Bool
    let path: FixPath
}

public extension OverlayGraph {

    func extractShapes(overlayRule: OverlayRule, minArea: FixFloat = 0) -> [FixShape] {
        var visited = self.links.filter(overlayRule: overlayRule)

        var holes = [FixPath]()
        var shapes = [FixShape]()
        
        for i in 0..<links.count {
            if !visited[i] {
                let contour = self.getContour(overlayRule: overlayRule, minArea: minArea, index: i, visited: &visited)
                
                if !contour.path.isEmpty {
                    if contour.isHole {
                        holes.append(contour.path)
                    } else {
                        shapes.append(FixShape(paths: [contour.path]))
                    }
                }
            }
        }

        shapes.join(holes: holes)
        
        return shapes
    }
    
    private func getContour(overlayRule: OverlayRule, minArea: FixFloat, index: Int, visited: inout [Bool]) -> Contour {
        var path = FixPath()
        var next = index

        var link = links[index]
        
        var a = link.a
        var b = link.b
        
        var leftLink = link

        var newVisited = [Int]()

        // find a closed tour
        repeat {
            newVisited.append(next)
            path.append(a.point)
            let node = nodes[b.index]
            
            if node.indices.count == 2 {
                next = node.other(index: next)
            } else {
                let isFillTop = overlayRule.isFillTop(fill: link.fill)
                let isCW = OverlayGraph.isClockwise(a: a.point, b: b.point, isTopInside: isFillTop)
                next = self.findNearestLinkTo(target: a, center: b, ignore: next, inClockWise: isCW, visited: visited)
                guard next >= 0 else {
                    break
                }
            }
            
            link = links[next]
            a = b
            b = link.other(b)

            // find leftmost and bottom link
            if leftLink.a.point.bitPack >= link.a.point.bitPack {
                let isSamePoint = leftLink.a.index == link.a.index
                let isSamePointAndTurnClockWise = isSamePoint && Triangle.isClockwise(p0: link.b.point, p1: link.a.point, p2: leftLink.b.point)
                
                if !isSamePoint || isSamePointAndTurnClockWise {
                    leftLink = link
                }
            }
            
        } while next != index

        let isHole = overlayRule.isFillBottom(fill: leftLink.fill)
        
        path.validate(minArea: minArea, isHole: isHole)
        
        for index in newVisited {
            visited[index] = true
        }

        return Contour(isHole: isHole, path: path)
    }

    private static func isClockwise(a: FixVec, b: FixVec, isTopInside: Bool) -> Bool {
        let isDirect = a.bitPack < b.bitPack

        return xnor(isDirect, isTopInside)
    }
    
    private static func xnor(_ a: Bool, _ b: Bool) -> Bool {
        a && b || !(a || b)
    }
    
}

private extension FixPath {
    
    // remove a short path and make cw if needed
    mutating func validate(minArea: FixFloat, isHole: Bool) {
        self.removeDegenerates()
        
        guard count > 2 else {
            self.removeAll()
            return
        }

        let uArea = self.unsafeArea
        let absArea = abs(uArea) >> (FixFloat.fractionBits + 1)

        if absArea < minArea {
            self.removeAll()
        } else if isHole && uArea > 0 || !isHole && uArea < 0 {
            // for holes must be negative and for contour must be positive
            self.reverse()
        }
    }
}

private extension Array where Element == FixShape {
    
    mutating func join(holes: [FixPath]) {
        guard !self.isEmpty && !holes.isEmpty else {
            return
        }
        
        if self.count == 1 {
            self[0].paths.reserveCapacity(holes.count + 1)
            self[0].addAsIs(holes)
        } else {
            self.scanJoin(holes: holes)
        }
    }
    
    private mutating func scanJoin(holes: [FixPath]) {
        var iPoints = [IdPoint]()
        iPoints.reserveCapacity(holes.count)
        for i in 0..<holes.count {
            iPoints.append(IdPoint(id: i, point: holes[i][0]))
        }
        
        iPoints.sort(by: { $0.point.x < $1.point.x })

        let xMin = iPoints[0].point.x
        let xMax = iPoints[iPoints.count - 1].point.x
        var yMin: Int32 = .max
        var yMax: Int32 = .min
        
        var floors = [Floor]()
        for i in 0..<self.count {
            floors.append(contentsOf: self[i].contour.floors(id: i, xMin: xMin, xMax: xMax, yMin: &yMin, yMax: &yMax))
        }
        
        floors.sort(by: { $0.seg.a.x < $1.seg.a.x })
        
        var scanList = JoinScanList(range: LineRange(min: yMin, max: yMax), count: floors.count)

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
            self[shapeIndex].paths.reserveCapacity(capacity + 1)
        }

        for holeIndex in 0..<holes.count {
            let hole = holes[holeIndex]
            let shapeIndex = holeShape[holeIndex]
            self[shapeIndex].addAsIs(hole)
        }
    }

}
