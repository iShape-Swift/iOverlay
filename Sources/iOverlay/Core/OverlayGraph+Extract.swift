//
//  OverlayGraph+Extract.swift
//  
//
//  Created by Nail Sharipov on 08.08.2023.
//

import iShape
import iFixFloat

public extension OverlayGraph {

    /// Extracts and returns shapes from the overlay graph based on the specified overlay rule and minimum area threshold.
    ///
    /// This method traverses the `OverlayGraph`, identifying and constructing shapes that meet the criteria defined by the `overlayRule`. Shapes with an area less than the specified `minArea` are excluded from the result, allowing for the filtration of negligible shapes.
    ///
    /// - Parameters:
    ///   - overlayRule: The rule determining how shapes are extracted from the overlay.
    ///   - minArea: The minimum area a shape must have to be included in the return value. This parameter helps in filtering out insignificant shapes or noise. Defaults to 0, which includes all shapes regardless of size.
    ///
    /// - Returns: An array of `FixShape`.
    func extractShapes(overlayRule: OverlayRule, minArea: Int64 = 0) -> [Shape] {
        var visited = self.links.filter(overlayRule: overlayRule)

        var holes = [Path]()
        var shapes = [Shape]()
        
        var j = 0
        while j < self.nodes.count {
            let i = self.findFirstLink(nodeIndex: j, visited: visited)
            guard i != .max else {
                j += 1
                continue
            }

            let isHole = overlayRule.isFillTop(fill: self.links[i].fill)
            var path = self.getPath(overlayRule: overlayRule, index: i, visited: &visited)
            if path.validate(minArea: minArea, isHole: isHole) {
                if isHole {
                    holes.append(path)
                } else {
                    shapes.append([path])
                }
            }
        }

        shapes.join(holes: holes)
        
        return shapes
    }
    
    private func getPath(overlayRule: OverlayRule, index: Int, visited: inout [Bool]) -> Path {
        var path = Path()
        var next = index

        var link = links[index]
        
        var a = link.a
        var b = link.b

        // find a closed tour
        repeat {
            path.append(a.point)
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

private extension Path {
    
    // remove a short path and make cw if needed
    mutating func validate(minArea: Int64, isHole: Bool) -> Bool {
        self.removeDegenerates()
        
        guard count > 2 else {
            return false
        }

        let uArea = self.unsafeArea
        let absArea = abs(uArea) >> 1

        if absArea < minArea {
            return false
        } else if isHole && uArea > 0 || !isHole && uArea < 0 {
            // for holes must be negative and for contour must be positive
            self.reverse()
        }
        
        return true
    }
}

private extension Array where Element == Shape {
    
    mutating func join(holes: [Path]) {
        guard !self.isEmpty && !holes.isEmpty else {
            return
        }
        
        if self.count == 1 {
            self[0].reserveCapacity(holes.count + 1)
            self[0].append(contentsOf: holes)
        } else {
            self.scanJoin(holes: holes)
        }
    }
    
    private mutating func scanJoin(holes: [Path]) {
        var iPoints = [IdPoint]()
        iPoints.reserveCapacity(holes.count)
        for i in 0..<holes.count {
            iPoints.append(IdPoint(id: i, point: holes[i][0]))
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
