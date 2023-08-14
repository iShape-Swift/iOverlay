//
//  OverlayGraph+Extract.swift
//  
//
//  Created by Nail Sharipov on 08.08.2023.
//

import iShape
import iFixFloat

public extension OverlayGraph {

    func extractShapes(fillRule: FillRule) -> [FixShape] {
        var visited = self.filter(fillRule: fillRule)

        var holes = [Contour]()
        var shapes = [FixShape]()
        var shapeBnds = [FixBnd]()
        
        for i in 0..<links.count {
            if !visited[i] {
                let contour = self.getContour(fillRule: fillRule, index: i, visited: &visited)
                
                if contour.isCavity {
                    holes.append(contour)
                } else {
                    shapes.append(FixShape(contour: contour.path, holes: []))
                    shapeBnds.append(contour.boundary)
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
            bestShape.holes.append(hole.path)
            
            shapes[bestShapeIndex] = bestShape
        }
        
        return shapes
    }
    
    private func getContour(fillRule: FillRule, index: Int, visited: inout [Bool]) -> Contour {
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
        
        if path.area < 0 {
            path.reverse()
        }
        
        for index in newVisited {
            visited[index] = true
        }

        return Contour(path: path, boundary: FixBnd(points: path), start: leftLink.a.point, isCavity: isCavity)
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
            return fill & SegmentFill.subjectTop == SegmentFill.subjectBottom
        case .clip:
            return fill & SegmentFill.clipTop == SegmentFill.clipBottom
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
