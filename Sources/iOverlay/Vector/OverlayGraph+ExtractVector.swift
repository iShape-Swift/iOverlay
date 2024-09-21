//
//  OverlayGraph+ExtractVector.swift
//
//
//  Created by Nail Sharipov on 30.01.2024.
//

import iFixFloat

struct StartVectorPathData {
    let a: Point
    let b: Point
    let nodeId: Int
    let linkId: Int
    let lastNodeId: Int
    let fill: SegmentFill
}

// similar as for extract shapes but for vectors
public extension OverlayGraph {
    
    func extractVectors(overlayRule: OverlayRule) -> [VectorShape] {
        var visited = self.links.filter(overlayRule: overlayRule)
        
        var holes = [VectorPath]()
        var shapes = [VectorShape]()

        var linkIndex = 0
        while linkIndex < visited.count {
            if visited[linkIndex] {
                linkIndex += 1
                continue
            }

            let leftTopLink = self.findLeftTopLink(linkIndex: linkIndex, visited: visited)
            let link = self.links[leftTopLink]
            let isHole = overlayRule.isFillTop(fill: link.fill)

            let startData: StartVectorPathData
            if isHole {
                startData = StartVectorPathData(
                    a: link.b.point,
                    b: link.a.point,
                    nodeId: link.a.id,
                    linkId: leftTopLink,
                    lastNodeId: link.b.id,
                    fill: link.fill
                )
                let path = self.getVectorPath(startData: startData, visited: &visited)
                holes.append(path)
            } else {
                startData = StartVectorPathData(
                    a: link.a.point,
                    b: link.b.point,
                    nodeId: link.b.id,
                    linkId: leftTopLink,
                    lastNodeId: link.a.id,
                    fill: link.fill
                )
                let path = self.getVectorPath(startData: startData, visited: &visited)
                shapes.append([path])
            }

            linkIndex += 1
        }
        
        shapes.join(holes: holes)
        
        return shapes
    }
    
    private func getVectorPath(startData: StartVectorPathData, visited: inout [Bool]) -> VectorPath {
        var linkId = startData.linkId
        var nodeId = startData.nodeId
        let lastNodeId = startData.lastNodeId

        visited[linkId] = true

        var path = VectorPath()
        path.append(VectorEdge(fill: startData.fill, a: startData.a, b: startData.b))

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
                path.append(VectorEdge(fill: link.fill, a: link.a.point, b: link.b.point))
                nodeId = link.b.id
            } else {
                path.append(VectorEdge(fill: link.fill, a: link.b.point, b: link.a.point))
                nodeId = link.a.id
            }

            visited[linkId] = true
        }

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
