//
//  OverlayGraph+Union.swift
//  
//
//  Created by Nail Sharipov on 08.08.2023.
//

import iFixFloat
import iShape

public extension OverlayGraph {
    
    func unionShapes() -> [FixShape] {
        var visited = self.filter(operation: .union)

        var holes = [Contour]()
        var shapes = [FixShape]()
        var shapeBnds = [FixBnd]()
        
        for i in 0..<links.count {
            if !visited[i] {
                let contour = self.getContour(index: i, visited: &visited)
                
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
        
        // find for each hole it shape
        for hole in holes {
            var bestDist = Int64.max
            var bestShapeIndex = -1

            for shapeIndex in 0..<shapes.count {

                let shape = shapes[shapeIndex]
                let shapeBnd = shapeBnds[shapeIndex]

                if shapeBnd.isInside(hole.boundary) {

                    let dist = shape.contour.getBottomVerticalDistance(p: hole.start)

                    if bestDist > dist {
                        bestDist = dist
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
    
    private func getContour(index: Int, visited: inout [Bool]) -> Contour {
        let top = SegmentFill.subjectTop | SegmentFill.clipTop
        let bottom = SegmentFill.subjectBottom | SegmentFill.clipBottom
        
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
                let isFillTop = link.fill & bottom == 0
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

        let isFillBottom = leftLink.fill & top == 0
        let isCavity = isFillBottom
        
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
