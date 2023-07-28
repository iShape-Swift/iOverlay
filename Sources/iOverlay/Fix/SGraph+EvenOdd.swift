//
//  SGraph+EvenOdd.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

import iFixFloat
import iShape

public extension SGraph {
    
    func partitionEvenOddShapes() -> [FixShape] {
        let n = links.count
        var visited = [Bool](repeating: false, count: n)

        var holes = [Contour]()
        var shapes = [FixShape]()
        var shapeBnds = [FixBnd]()
        
        for i in 0..<n {
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
            var bestMark = VerticalDistanceMarker.empty
            var bestShapeIndex = -1

            for shapeIndex in 0..<shapes.count {

                let shape = shapes[shapeIndex]
                let shapeBnd = shapeBnds[shapeIndex]

                if shapeBnd.isInside(hole.boundary) {

                    let vDistMark = shape.contour.getVerticalMarker(p: hole.start)

                    if vDistMark.isBetter(bestMark) {
                        bestMark = vDistMark
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
        var path = FixPath()
        var next = index

        var link = links[index]

        var a = link.a
        var b = link.b
        
        var leftLink = link
        
        // find a closed tour
        repeat {
            path.append(a.point)
            visited[next] = true
            let node = nodes[b.index]
            
            if node.count == 2 {
                next = node.other(index: next)
            } else {
                let isCW = SGraph.isClockwise(a: a.point, b: b.point, isTopInside: link.fill == .subjectTop)
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

        let isCavity = leftLink.fill == .subjectBottom
        
        if path.area < 0 {
            path.reverse()
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
