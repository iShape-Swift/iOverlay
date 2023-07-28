//
//  SGraph.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

import iFixFloat
import iShape

public struct SGraph {
    
    let nodes: [SNode]
    let indices: [Int]
    let links: [SLink]

    init(segments: [Segment]) {
        let n = segments.count
        var links = [SLink](repeating: .init(a: .zero, b: .zero, fill: 0), count: n)
        
        var vStore = [FixVec: Int]()
        vStore.reserveCapacity(2 * n)
        
        for i in 0..<n {
            let s = segments[i]
            let ai = vStore.place(s.a)
            let bi = vStore.place(s.b)
            
            links[i] = SLink(
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
        var nodes = [SNode](repeating: SNode(data0: 0, data1: 0, count: 0), count: m)
        var offset = 0

        for i in 0..<m {
            let nC = nCount[i]
            if nC > 2 {
                nodes[i] = SNode(data0: offset, data1: 0, count: nC)
                offset += nC
            } else {
                nodes[i] = SNode(data0: -1, data1: -1, count: nC)
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

private extension SNode {
    
    mutating func add(_ index: Int, indices: inout [Int]) {
        if count == 2 {
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
