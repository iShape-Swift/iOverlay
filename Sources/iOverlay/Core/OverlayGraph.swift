//
//  OverlayGraph.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

import iFixFloat
import iShape

private struct End {
    let segIndex: Int
    let point: Point
}

/// A representation of geometric shapes organized for efficient boolean operations.
///
/// `OverlayGraph` is a core structure designed to facilitate the execution of boolean operations on shapes, such as union, intersection, and difference. It organizes and preprocesses geometric data, making it optimized for these operations. This struct is the result of compiling shape data into a form where boolean operations can be applied directly, efficiently managing the complex relationships between different geometric entities.
///
/// Use `OverlayGraph` to perform boolean operations on the geometric shapes you've added to an `Overlay`, after it has processed the shapes according to the specified fill and overlay rules.
public struct OverlayGraph {
    
    let nodes: [OverlayNode]
    let links: [OverlayLink]
    
    init(segments: [Segment]) {
        let n = segments.count
        
        guard n > 0 else {
            nodes = []
            links = []
            return
        }
        
        var endBs = [End]()
        endBs.reserveCapacity(n)
        for segIndex in 0..<n {
            endBs.append(End(segIndex: segIndex, point: segments[segIndex].seg.b))
        }
        
        endBs.sort(by: { $0.point < $1.point })
        
        var nodes = [OverlayNode]()
        nodes.reserveCapacity(2 * n)
        
        var links = segments.map({ OverlayLink(a: .zero, b: .zero, fill: $0.fill) })
        
        var ai = 0
        var bi = 0
        var a = segments[0].seg.a
        var b = endBs[0].point
        
        while ai < n || bi < n {
            var cnt = 0
            if a == b {
                cnt += segments.size(point: a, index: ai)
                cnt += endBs.size(point: b, index: bi)
            } else if ai < n && a < b {
                cnt += segments.size(point: a, index: ai)
            } else {
                cnt += endBs.size(point: b, index: bi)
            }
            
            var indices = [Int]()
            indices.reserveCapacity(cnt)
            
            if a == b {
                let ip = IdPoint(id: nodes.count, point: a)
                while ai < n {
                    let aa = segments[ai].seg.a
                    guard aa == a else {
                        a = aa
                        break
                    }
                    links[ai].a = ip
                    indices.append(ai)
                    
                    ai += 1
                }

                while bi < n {
                    let e = endBs[bi]
                    guard e.point == b else {
                        b = e.point
                        break
                    }
                    links[e.segIndex].b = ip
                    indices.append(e.segIndex)
                    
                    bi += 1
                }
            } else if ai < n && a < b {
                let ip = IdPoint(id: nodes.count, point: a)
                while ai < n {
                    let aa = segments[ai].seg.a
                    guard aa == a else {
                        a = aa
                        break
                    }
                    links[ai].a = ip
                    indices.append(ai)
                    
                    ai += 1
                }
            } else {
                let ip = IdPoint(id: nodes.count, point: b)
                while bi < n {
                    let e = endBs[bi]
                    guard e.point == b else {
                        b = e.point
                        break
                    }
                    links[e.segIndex].b = ip
                    indices.append(e.segIndex)
                    
                    bi += 1
                }
            }
            
            assert(indices.count > 1)
            nodes.append(OverlayNode(indices: indices))
        }
        
        self.links = links
        self.nodes = nodes
    }

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

private extension Array where Element == Segment {
    
    func size(point: Point, index: Int) -> Int {
        var i = index
        while i < self.count && self[i].seg.a == point {
            i += 1
        }
        return i - index
    }
}

private extension Array where Element == End {
    
    func size(point: Point, index: Int) -> Int {
        var i = index
        while i < self.count && self[i].point == point {
            i += 1
        }

        return i - index
    }
}
