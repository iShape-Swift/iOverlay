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
    /// - Returns: An array of `Shape`.
    ///
    /// # Shape Representation
    /// The output is a `[[[IntPoint]]]`, where:
    /// - The outer `[Shape]` represents a set of shapes.
    /// - Each shape `[Path]` represents a collection of paths, where the first path is the outer boundary, and all subsequent paths are holes in this boundary.
    /// - Each path `[IntPoint]` is a sequence of points, forming a closed path.
    ///
    /// Note: Outer boundary paths have a clockwise order, and holes have a counterclockwise order.
    func extractShapes(overlayRule: OverlayRule, minArea: Int64 = 0) -> [Shape] {
        var visited = self.links.filter(overlayRule: overlayRule)

        var holes = [Path]()
        var shapes = [Shape]()
        
        var linkIndex = 0
        while linkIndex < visited.count {
            if visited[linkIndex] {
                linkIndex += 1
                continue
            }

            let leftTopLink = self.findLeftTopLink(linkIndex: linkIndex, visited: visited)
            let link = self.links[leftTopLink]
            let isHole = overlayRule.isFillTop(fill: link.fill)

            let startData: StartPathData
            if isHole {
                startData = StartPathData(begin: link.b.point, nodeId: link.a.id, linkId: leftTopLink, lastNodeId: link.b.id)
            } else {
                startData = StartPathData(begin: link.a.point, nodeId: link.b.id, linkId: leftTopLink, lastNodeId: link.a.id)
            }

            var path = self.getPath(startData: startData, visited: &visited)

            if path.validate(minArea: minArea) {
                if isHole {
                    holes.append(path)
                } else {
                    shapes.append([path])
                }
            }

            linkIndex += 1
        }

        shapes.join(holes: holes)
        
        return shapes
    }
    
    private func getPath(startData: StartPathData, visited: inout [Bool]) -> Path {
        var linkId = startData.linkId
        var nodeId = startData.nodeId
        let lastNodeId = startData.lastNodeId

        visited[linkId] = true

        var path = Path()
        path.append(startData.begin)

        // Find a closed tour
        while nodeId != lastNodeId {
            let node = self.nodes[nodeId]
            if node.indices.count == 2 {
                linkId = node.other(index: linkId)
            } else {
                linkId = self.findNearestCounterWiseLinkTo(targetIndex: linkId, nodeId: nodeId, visited: visited)
            }
            let link = self.links[linkId]
            if link.a.id == nodeId {
                path.append(link.a.point)
                nodeId = link.b.id
            } else {
                path.append(link.b.point)
                nodeId = link.a.id
            }

            visited[linkId] = true
        }

        return path
    }
    
    @inline(__always)
    func findLeftTopLink(linkIndex: Int, visited: [Bool]) -> Int {
        var topIndex = linkIndex
        var top = self.links[linkIndex]
        assert(top.isDirect)

        let node = self.nodes[top.a.id]

        // find most top link

        for i in node.indices {
            if i == linkIndex {
                continue
            }
            let link = self.links[i]
            if !link.isDirect || Triangle.isClockwise(p0: top.a.point, p1: top.b.point, p2: link.b.point) {
                continue
            }

            if visited[i] {
                continue
            }

            topIndex = i
            top = link
        }

        return topIndex
    }
}

struct StartPathData {
    let begin: Point
    let nodeId: Int
    let linkId: Int
    let lastNodeId: Int
}

private extension Path {
    
    // remove a short path and make cw if needed
    mutating func validate(minArea: Int64) -> Bool {
        self.removeDegenerates()
        
        guard count > 2 else {
            return false
        }
        
        guard minArea > 0 else {
            return true
        }
        
        
        let uArea = self.unsafeArea
        let absArea = abs(uArea) >> 1
        
        return absArea < minArea
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
