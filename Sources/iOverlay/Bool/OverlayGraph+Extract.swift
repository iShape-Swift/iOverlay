//
//  OverlayGraph+Extract.swift
//  
//
//  Created by Nail Sharipov on 08.08.2023.
//

import iShape
import iFixFloat

public extension OverlayGraph {

    func extractShapes(fillRule: FillRule, minArea: FixFloat = 16) -> [FixShape] {
        var visited = self.links.filter(fillRule: fillRule)

        var holes = [Contour]()
        var shapes = [FixShape]()
        var shapeBnds = [FixBnd]()
        
        for i in 0..<links.count {
            if !visited[i] {
                let contour = self.getContour(fillRule: fillRule, minArea: minArea, index: i, visited: &visited)
                
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
        
        // find for each hole its shape
        for hole in holes {
            var minDist = Int64.max
            var bestShapeIndex = -1

            for shapeIndex in 0..<shapes.count {

                let shape = shapes[shapeIndex]
                let shapeBnd = shapeBnds[shapeIndex]

                if shapeBnd.isInside(hole.boundary) {

                    let dist = shape.contour.getBottomVerticalDistance(p: hole.start)

                    if minDist > dist {
                        minDist = dist
                        bestShapeIndex = shapeIndex
                    }
                }
            }
            
            var bestShape = shapes[bestShapeIndex]
            bestShape.addHole(hole.path)
            
            shapes[bestShapeIndex] = bestShape
        }
        
        return shapes
    }
    
    private func getContour(fillRule: FillRule, minArea: FixFloat, index: Int, visited: inout [Bool]) -> Contour {
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
            
            if node.count == 2 {
                next = node.other(index: next)
            } else {
                let isFillTop = fillRule.isFillTop(fill: link.fill)
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

        let isCavity = fillRule.isFillBottom(fill: leftLink.fill)
        
        path.validate(minArea: minArea)
        
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

private extension FillRule {
    
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
    mutating func validate(minArea: FixFloat) {
        self.removeDegenerates()
        
        guard count > 2 else {
            self.removeAll()
            return
        }

        let area = self.area

        if abs(area) < minArea {
            self.removeAll()
        } else if area < 0 {
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
                    let y = FixPath.getVerticalIntersection(p0: a, p1: b, p: p)
                    
                    if p.y > y && y > nearestY {
                        nearestY = y
                    }
                }
            }

            p0 = pi
        }

        return p.y - nearestY
    }
    
    private static func getVerticalIntersection(p0: FixVec, p1: FixVec, p: FixVec) -> Int64 {
        let y01 = p0.y - p1.y
        let x01 = p0.x - p1.x
        let xx0 = p.x - p0.x

        return (y01 * xx0) / x01 + p0.y
    }
}

private struct Contour {
    let path: FixPath       // Array of points in clockwise order
    let boundary: FixBnd    // Smallest bounding box of the path
    let start: FixVec       // Leftmost point in the path
    let isCavity: Bool      // True if path is an internal cavity (hole), false if external (hull)
}
