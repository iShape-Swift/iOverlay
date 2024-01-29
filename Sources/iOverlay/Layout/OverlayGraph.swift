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
    let bitPack: BitPack
}

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
            endBs.append(End(segIndex: segIndex, bitPack: segments[segIndex].seg.b.bitPack))
        }
        
        endBs.sort(by: { $0.bitPack < $1.bitPack })
        
        var nodes = [OverlayNode]()
        nodes.reserveCapacity(2 * n)
        
        var links = segments.map({ OverlayLink(a: .zero, b: .zero, fill: $0.fill) })
        
        var ai = 0
        var bi = 0
        var a = segments[0].seg.a.bitPack
        var b = endBs[0].bitPack
        
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
                let ip = IndexPoint(index: nodes.count, point: a.fixVec)
                while ai < n {
                    let aa = segments[ai].seg.a.bitPack
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
                    guard e.bitPack == b else {
                        b = e.bitPack
                        break
                    }
                    links[e.segIndex].b = ip
                    indices.append(e.segIndex)
                    
                    bi += 1
                }
            } else if ai < n && a < b {
                let ip = IndexPoint(index: nodes.count, point: a.fixVec)
                while ai < n {
                    let aa = segments[ai].seg.a.bitPack
                    guard aa == a else {
                        a = aa
                        break
                    }
                    links[ai].a = ip
                    indices.append(ai)
                    
                    ai += 1
                }
            } else {
                let ip = IndexPoint(index: nodes.count, point: b.fixVec)
                while bi < n {
                    let e = endBs[bi]
                    guard e.bitPack == b else {
                        b = e.bitPack
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
    func findNearestLinkTo(target: IndexPoint, center: IndexPoint, ignore: Int, inClockWise: Bool, visited: [Bool]) -> Int {
        let node = nodes[center.index]

        // find first not visited vector
        guard var i = node.indices.firstIndex(where: { $0 != ignore && !visited[$0] }) else {
            return -1
        }
        
        var minIndex = node.indices[i]
        
        var minVec = links[minIndex].other(center).point - center.point
        let v0 = target.point - center.point // base vector
        
        // compare minVec with the rest of the vectors
        
        i += 1
        while i < node.indices.count {
            let j = node.indices[i]
            if !visited[j] && ignore != j {
                let vj = links[j].other(center).point - center.point
                
                if v0.isCloserInRotation(to: vj, comparedTo: minVec) == inClockWise {
                    minVec = vj
                    minIndex = j
                }
            }
            i += 1
        }

        return minIndex
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
    
    func size(point: BitPack, index: Int) -> Int {
        var i = index
        while i < self.count && self[i].seg.a.bitPack == point {
            i += 1
        }
        return i - index
    }
}

private extension Array where Element == End {
    
    func size(point: BitPack, index: Int) -> Int {
        var i = index
        while i < self.count && self[i].bitPack == point {
            i += 1
        }

        return i - index
    }
}
