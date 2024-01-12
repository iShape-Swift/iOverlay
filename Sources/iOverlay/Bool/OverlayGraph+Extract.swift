//
//  OverlayGraph+Extract.swift
//  
//
//  Created by Nail Sharipov on 08.08.2023.
//

import iShape
import iFixFloat


public extension OverlayGraph {

    func extractShapes(overlayRule: OverlayRule, minArea: FixFloat = 0) -> [FixShape] {
        var visited = self.links.filter(overlayRule: overlayRule)

        var holes = [Contour]()
        var shapes = [FixShape]()
        var shapeBnds = [FixBnd]()
        
        for i in 0..<links.count {
            if !visited[i] {
                let contour = self.getContour(overlayRule: overlayRule, minArea: minArea, index: i, visited: &visited)
                
                if !contour.path.isEmpty {
                    if contour.isCavity {
                        holes.append(contour)
                    } else {
                        shapes.append(FixShape(contour: contour.path, holes: []))
                        shapeBnds.append(contour.boundary)
                    }
                }
            }
        }

        guard !holes.isEmpty else {
            return shapes
        }
        
        if shapes.count > 1 {
            var shapeCandidates = [Int]()
            
            // find for each hole its shape
            var holeCounter = [Int: Int]()
            var holeShape = [Int](repeating: 0, count: holes.count)
            holeCounter.reserveCapacity(holes.count)
            for (index, hole) in holes.enumerated() {
                
                shapeCandidates.removeAll(keepingCapacity: true)
                
                for shapeIndex in 0..<shapes.count {

                    let shapeBnd = shapeBnds[shapeIndex]

                    if shapeBnd.isInside(hole.boundary) {
                        shapeCandidates.append(shapeIndex)
                    }
                }
                
                assert(!shapeCandidates.isEmpty)

                var bestShapeIndex = -1
                
                if shapeCandidates.count <= 1 {
                    bestShapeIndex = shapeCandidates[0]
                } else {
                    var minDist = Int64.max
                    
                    for shapeIndex in shapeCandidates {
                        let dist = shapes[shapeIndex].contour.getBottomVerticalDistance(p: hole.start)
                        if minDist > dist {
                            minDist = dist
                            bestShapeIndex = shapeIndex
                        }
                    }
                }
                
                holeShape[index] = bestShapeIndex
                holeCounter[bestShapeIndex, default: 0] += 1
            }
            
            for (shapeIndex, holeCount) in holeCounter {
                shapes[shapeIndex].paths.reserveCapacity(holeCount + 1)
            }
            
            for (index, hole) in holes.enumerated() {
                let shapeIndex = holeShape[index]
                shapes[shapeIndex].addHole(hole.path)
            }
        } else {
            shapes[0].paths.reserveCapacity(holes.count + 1)
            for hole in holes {
                shapes[0].addHole(hole.path)
            }
        }
        
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

        let isCavity = overlayRule.isFillBottom(fill: leftLink.fill)
        
        path.validate(minArea: minArea, isCavity: isCavity)
        
        for index in newVisited {
            visited[index] = true
        }

        let boundary = !path.isEmpty ? FixBnd(points: path) : FixBnd.zero

        return Contour(path: path, boundary: boundary, start: leftLink.a.point, isCavity: isCavity)
    }

    private static func isClockwise(a: FixVec, b: FixVec, isTopInside: Bool) -> Bool {
        let isDirect = a.bitPack < b.bitPack

        return xnor(isDirect, isTopInside)
    }
    
    private static func xnor(_ a: Bool, _ b: Bool) -> Bool {
        a && b || !(a || b)
    }

}

private extension OverlayRule {
    
    func isFillTop(fill: SegmentFill) -> Bool {
        switch self {
        case .subject:
            return fill & SegmentFill.subjectTop == SegmentFill.subjectTop
        case .clip:
            return fill & SegmentFill.clipTop == SegmentFill.clipTop
        case .intersect:
            return fill & SegmentFill.bothTop == SegmentFill.bothTop
        case .union:
            return fill & SegmentFill.bothBottom == 0
        case .difference:
            return fill & SegmentFill.bothTop == SegmentFill.subjectTop
        case .xor:
            let isSubject = fill & SegmentFill.bothTop == SegmentFill.subjectTop
            let isClip = fill & SegmentFill.bothTop == SegmentFill.clipTop
            
            return isSubject || isClip
        }
    }

    func isFillBottom(fill: SegmentFill) -> Bool {
        switch self {
        case .subject:
            return fill & SegmentFill.subjectBottom == SegmentFill.subjectBottom
        case .clip:
            return fill & SegmentFill.clipBottom == SegmentFill.clipBottom
        case .intersect:
            return fill & SegmentFill.bothBottom == SegmentFill.bothBottom
        case .union:
            return fill & SegmentFill.bothTop == 0
        case .difference:
            return fill & SegmentFill.bothBottom == SegmentFill.subjectBottom
        case .xor:
            let isSubject = fill & SegmentFill.bothBottom == SegmentFill.subjectBottom
            let isClip = fill & SegmentFill.bothBottom == SegmentFill.clipBottom
            
            return isSubject || isClip
        }
    }
    
}

private extension FixPath {
    
    // remove a short path and make cw if needed
    mutating func validate(minArea: FixFloat, isCavity: Bool) {
        self.removeDegenerates()
        
        guard count > 2 else {
            self.removeAll()
            return
        }

        let uArea = self.unsafeArea
        let absArea = abs(uArea) >> (FixFloat.fractionBits + 1)

        if absArea < minArea {
            self.removeAll()
        } else if isCavity && uArea > 0 || !isCavity && uArea < 0 {
            // for holes must be negative and for contour must be positive
            self.reverse()
        }
    }
    
    // points of holes can not have any common points with hull
    func getBottomVerticalDistance(p: FixVec) -> Int64 {
        var p0 = self[count - 1]
        var nearestY = Int64.min
        
        for pi in self {
            // any bottom and non vertical
            
            if p0.x != pi.x {
                let a: FixVec
                let b: FixVec
                
                if p0.x < pi.x {
                    a = p0
                    b = pi
                } else {
                    a = pi
                    b = p0
                }
                
                if a.x <= p.x && p.x <= b.x {
                    let y = FixPath.getVerticalIntersection(p0: a, p1: b, x: p.x)
                    
                    if p.y > y && y > nearestY {
                        nearestY = y
                    }
                }
            }

            p0 = pi
        }
        assert(nearestY != Int64.min)

        return p.y - nearestY
    }
    
    private static func getVerticalIntersection(p0: FixVec, p1: FixVec, x: FixFloat) -> Int64 {
        let y01 = p0.y - p1.y
        let x01 = p0.x - p1.x
        let xx0 = x - p0.x

        return (y01 * xx0) / x01 + p0.y
    }
}

private struct Contour {
    let path: FixPath       // Array of points in clockwise order
    let boundary: FixBnd    // Smallest bounding box of the path
    let start: FixVec       // Leftmost point in the path
    let isCavity: Bool      // True if path is an internal cavity (hole), false if external (hull)
}
