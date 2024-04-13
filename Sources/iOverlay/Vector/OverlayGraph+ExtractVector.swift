//
//  OverlayGraph+ExtractVector.swift
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
            let fill = SideFill(fill: link.fill, a: a.point, b: b.point)
            path.append(VectorEdge(fill: fill, a: a.point, b: b.point))
            let node = nodes[b.id]
            
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
        
        var segments = [IdSegment]()
        for i in 0..<self.count {
            segments.append(contentsOf: self[i][0].idSegments(id: i, xMin: xMin, xMax: xMax))
        }
        
        segments.sort(by: { $0.xSegment.a.x < $1.xSegment.a.x })

        let solution = ShapeBinder.solve(shapeCount: self.count, iPoints: iPoints, segments: segments)

        
        for shapeIndex in 0..<solution.childrenCountForParent.count {
            let capacity = solution.childrenCountForParent[shapeIndex]
            self[shapeIndex].reserveCapacity(capacity + 1)
        }

        for holeIndex in 0..<holes.count {
            let hole = holes[holeIndex]
            let shapeIndex = solution.parentForChild[holeIndex]
            self[shapeIndex].append(hole)
        }
    }

}

private extension VectorPath {
    
    // remove a short path and make cw if needed
    mutating func validate(isHole: Bool) {
        let isPositive = self.isPositive

        if isHole && !isPositive || !isHole && isPositive {
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
