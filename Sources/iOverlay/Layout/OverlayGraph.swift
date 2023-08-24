//
//  OverlayGraph.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

import iFixFloat
import iShape

public struct OverlayGraph {
    
    let nodes: [OverlayNode]
    let indices: [Int]
    let links: [OverlayLink]
    
    init(segments: [Segment]) {
        let n = segments.count
        var links = [OverlayLink](repeating: .init(a: .zero, b: .zero, fill: 0), count: n)
        
        var vStore = [FixVec: Int]()
        vStore.reserveCapacity(2 * n)
        
        for i in 0..<n {
            let s = segments[i]
            let ai = vStore.place(s.a)
            let bi = vStore.place(s.b)
            
            links[i] = OverlayLink(
                a: IndexPoint(index: ai, point: s.a),
                b: IndexPoint(index: bi, point: s.b),
                fill: s.fill
            )
        }
        
        let m = vStore.count
        var nCount = [Int](repeating: 0, count: m)
        for i in 0..<n {
            let l = links[i]
            
            nCount[l.a.index] = nCount[l.a.index] + 1
            nCount[l.b.index] = nCount[l.b.index] + 1
        }
        
        var nl = 0
        for i in 0..<m {
            let nc = nCount[i]
            if nc > 2 {
                nl += nc
            }
        }
        
        var indices = [Int](repeating: 0, count: nl)
        var nodes = [OverlayNode](repeating: OverlayNode(data0: 0, data1: 0, count: 0), count: m)
        var offset = 0

        for i in 0..<m {
            let nC = nCount[i]
            assert(nC > 1)
            
            if nC == 1 {
                print("Assert")
            }
            
            if nC != 2 {
                nodes[i] = OverlayNode(data0: offset, data1: 0, count: nC)
                offset += nC
            } else {
                nodes[i] = OverlayNode(data0: -1, data1: -1, count: nC)
            }
        }
        
        for i in 0..<n {
            let link = links[i]
            
            var nodeA = nodes[link.a.index]
            nodeA.add(i, indices: &indices)
            nodes[link.a.index] = nodeA
            
            var nodeB = nodes[link.b.index]
            nodeB.add(i, indices: &indices)
            nodes[link.b.index] = nodeB
        }
        
        self.nodes = nodes
        self.indices = indices
        self.links = links
    }
    
    // Finds the nearest link to a given target point.
    func findNearestLinkTo(target: IndexPoint, center: IndexPoint, ignore: Int, inClockWise: Bool, visited: [Bool]) -> Int {
        let node = nodes[center.index]

        // find any not visited vector
        
        var i = node.data0
        let last = i + node.count

        var minIndex = -1
        
        while i < last {
            let j = indices[i]
            if !visited[j] && ignore != j {
                minIndex = j
                break
            }
            i += 1
        }
        
        guard minIndex >= 0 else {
            return -1
        }
        
        var minVec = links[minIndex].other(center).point - center.point
        let v0 = target.point - center.point // base vector
        
        // compare minVec with the rest of the vectors
        
        i += 1
        while i < last {
            let j = indices[i]
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

private extension Dictionary where Key == FixVec, Value == Int {
    
    mutating func place(_ point: FixVec) -> Int {
        if let i = self[point] {
            return i
        } else {
            let i = count
            self[point] = i
            return i
        }
    }
}

private extension OverlayNode {
    
    mutating func add(_ index: Int, indices: inout [Int]) {
        if count <= 2 {
            if data0 == -1 {
                data0 = index
            } else {
                data1 = index
            }
        } else {
            indices[data0 + data1] = index
            data1 += 1
        }
    }
}

private extension FixVec {
    
    // v, a, b vectors are multidirectional
    func isCloserInRotation(to a: FixVec, comparedTo b: FixVec) -> Bool {
        let crossA = self.unsafeCrossProduct(a)
        let crossB = self.unsafeCrossProduct(b)

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

        let crossAB = a.unsafeCrossProduct(b)
        
        return crossAB < 0
    }

}
