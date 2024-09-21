//
//  OverlayGraph.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

import iFixFloat
import iShape

/// A representation of geometric shapes organized for efficient boolean operations.
///
/// `OverlayGraph` is a core structure designed to facilitate the execution of boolean operations on shapes, such as union, intersection, and difference. It organizes and preprocesses geometric data, making it optimized for these operations. This struct is the result of compiling shape data into a form where boolean operations can be applied directly, efficiently managing the complex relationships between different geometric entities.
///
/// Use `OverlayGraph` to perform boolean operations on the geometric shapes you've added to an `Overlay`, after it has processed the shapes according to the specified fill and overlay rules.
public struct OverlayGraph {
    
    let nodes: [OverlayNode]
    let links: [OverlayLink]
    
    init(segments: [Segment], fills: [SegmentFill]) {
        let n = segments.count
        
        guard n > 0 else {
            nodes = []
            links = []
            return
        }
        
        var links = [OverlayLink]()
        links.reserveCapacity(n)
        for index in 0..<n {
            let fill = fills[index]
            let segm = segments[index].xSegment
            let a = IdPoint(id: 0, point: segm.a)
            let b = IdPoint(id: 0, point: segm.b)
            links.append(OverlayLink(a: a, b: b, fill: fill))
        }
        
        var endBs = [End]()
        endBs.reserveCapacity(n)
        for index in 0..<n {
            endBs.append(End(index: index, point: segments[index].xSegment.b))
        }
        
        endBs.sort(by: { $0.point < $1.point })
        
        var nodes = [OverlayNode]()
        nodes.reserveCapacity(n)
        
        var ai = 0
        var bi = 0
        var a = links[0].a.point
        var b = endBs[0].point
        var nextAcnt = links.size(point: a, index: ai)
        var nextBcnt = endBs.size(point: b, index: bi)
        while nextAcnt > 0 || nextBcnt > 0 {
            let aCnt: Int
            let bCnt: Int
            if a == b {
                aCnt = nextAcnt
                bCnt = nextBcnt
            } else if nextAcnt > 0 && a < b {
                aCnt = nextAcnt
                bCnt = 0
            } else {
                aCnt = 0
                bCnt = nextBcnt
            }
            
            let nodeId = nodes.count
            var indices = [Int]()
            indices.reserveCapacity(aCnt + bCnt)
            
            if aCnt > 0 {
                nextAcnt = 0
                for _ in 0..<aCnt {
                    links[ai].a.id = nodeId
                    indices.append(ai)
                    ai += 1
                }
                if ai < n {
                    a = links[ai].a.point
                    nextAcnt = links.size(point: a, index: ai)
                }
            }
            
            if bCnt > 0 {
                nextBcnt = 0
                for _ in 0..<bCnt {
                    let e = endBs[bi]
                    indices.append(e.index)
                    links[e.index].b.id = nodeId
                    bi += 1
                }
                
                if bi < n {
                    b = endBs[bi].point
                    nextBcnt = endBs.size(point: b, index: bi)
                }
            }
            
            assert(indices.count > 1)
            nodes.append(OverlayNode(indices: indices))
        }
        
        self.links = links
        self.nodes = nodes
    }
    
    func findNearestCounterWiseLinkTo(targetIndex: Int, nodeId: Int, visited: [Bool]) -> Int {
        let target = self.links[targetIndex]
        
        let a, c: Point
        if target.a.id == nodeId {
            c = target.a.point
            a = target.b.point
        } else {
            c = target.b.point
            a = target.a.point
        }

        let node = self.nodes[nodeId]

        var (itIndex, bestIndex) = node.firstNotVisited(visited: visited)

        var linkIndex = node.nextLink(itIndex: &itIndex, visited: visited)

        if linkIndex >= self.links.count {
            // no more links
            return bestIndex
        }

        let va = a.subtract(c)
        let b = self.links[bestIndex].other(nodeId).point
        var vb = b.subtract(c)
        var more180 = va.crossProduct(vb) <= 0

        while linkIndex < self.links.count {
            let link = self.links[linkIndex]
            let p = link.other(nodeId).point
            let vp = p.subtract(c)
            let newMore180 = va.crossProduct(vp) <= 0

            if newMore180 == more180 {
                // both more 180 or both less 180
                let isClockWise = vp.crossProduct(vb) > 0
                if isClockWise {
                    bestIndex = linkIndex
                    vb = vp
                }
            } else if more180 {
                // new less 180
                more180 = false
                bestIndex = linkIndex
                vb = vp
            }

            linkIndex = node.nextLink(itIndex: &itIndex, visited: visited)
        }

        return bestIndex
    }
    
}
    /*

    // Finds the nearest link to a given target point.
    func findNearestLinkTo(target: IdPoint, center: IdPoint, ignore: Int, inClockWise: Bool, visited: [Bool]) -> Int {
        let node = nodes[center.id]

        // find first not visited vector
        guard var i = node.indices.firstIndex(where: { $0 != ignore && !visited[$0] }) else {
            return -1
        }
        
        var minIndex = node.indices[i]
        
        var minVec = links[minIndex].other(center).point.subtract(center.point)
        let v0 = target.point.subtract(center.point) // base vector
        
        // compare minVec with the rest of the vectors
        
        i += 1
        while i < node.indices.count {
            let j = node.indices[i]
            if !visited[j] && ignore != j {
                let vj = links[j].other(center).point.subtract(center.point)
                
                if v0.isCloserInRotation(to: vj, comparedTo: minVec) == inClockWise {
                    minVec = vj
                    minIndex = j
                }
            }
            i += 1
        }

        return minIndex
    }
    
    func findFirstLink(nodeIndex: Int, visited: [Bool]) -> Int {
        let node = self.nodes[nodeIndex]
        var j = Int.max
        for i in node.indices {
            if !visited[i] {
                if j == .max {
                    j = i
                } else {
                    let a = self.links[j].a.point
                    let bj = self.links[j].b.point
                    let bi = self.links[i].b.point

                    if Triangle.isClockwise(p0: a, p1: bi, p2: bj) {
                        j = i
                    }
                }
            }
        }

        return j
    }

    static func isClockwise(a: Point, b: Point, isTopInside: Bool) -> Bool {
        xnor(a < b, isTopInside)
    }
    
    private static func xnor(_ a: Bool, _ b: Bool) -> Bool {
        a && b || !(a || b)
    }
    
}

private extension FixVec {
    
    // v, a, b vectors are multidirectional
    func isCloserInRotation(to a: FixVec, comparedTo b: FixVec) -> Bool {
        let crossA = self.crossProduct(a)
        let crossB = self.crossProduct(b)

        guard crossA != 0 && crossB != 0 else {
            // vectors are collinear
            if crossA == 0 {
                // a is opposite to self, so based on crossB
                return crossB > 0
            } else {
                // b is opposite to self, so based on crossA
                return crossA < 0
            }
        }
        
        let sameSide = crossA > 0 && crossB > 0 || crossA < 0 && crossB < 0
        
        guard sameSide else {
            return crossA < 0
        }

        let crossAB = a.crossProduct(b)
        
        return crossAB < 0
    }

}
*/
private extension Array where Element == OverlayLink {
    
    func size(point: Point, index: Int) -> Int {
        var i = index + 1
        while i < self.count && self[i].a.point == point {
            i += 1
        }
        return i - index
    }
}

private extension Array where Element == End {
    
    func size(point: Point, index: Int) -> Int {
        var i = index + 1
        while i < self.count && self[i].point == point {
            i += 1
        }

        return i - index
    }
}
