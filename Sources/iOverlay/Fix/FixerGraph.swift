//
//  FixerGraph.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iFixFloat
import iShape

private struct IxEdge {
    let a: Int
    let b: Int
}

struct FixerNode {
    let isStar: Bool
    let index: Int
    var data0: Int  // start
    var data1: Int  // count
    let point: FixVec
}

struct FixerGraph {

    private let nodes: [FixerNode]
    private let starIndices: [Int]
    
    var count: Int { nodes.count }
    
    var first: FixerNode {
        var result = nodes[0]
        for node in nodes {
            if result.point.bitPack > node.point.bitPack {
                result = node
            }
        }
        
        return result
    }
    
    func starNeighbors(node: FixerNode) -> [FixerNode] {
        assert(node.isStar)
        var result = [FixerNode](repeating: .init(isStar: false, index: 0, data0: 0, data1: 0, point: .zero), count: node.data1)
        var j = 0
        for i in node.data0..<node.data0 + node.data1 {
            let index = starIndices[i]
            result[j] = nodes[index]
            j += 1
        }
        return result
    }
    
    func neighbors(node: FixerNode) -> [FixerNode] {
        if node.isStar {
            return starNeighbors(node: node)
        } else {
            return [nodes[node.data0], nodes[node.data1]]
        }
    }

    func nextStar(node: FixerNode, exclude: FixerNode) -> [FixerNode] {
        assert(node.isStar)
        var result = [FixerNode](repeating: .init(isStar: false, index: 0, data0: 0, data1: 0, point: .zero), count: node.data1 - 1)
        var j = 0
        for i in node.data0..<node.data0 + node.data1 {
            let index = starIndices[i]
            if index != exclude.index {
                result[j] = nodes[index]
                j += 1
            }
        }
        return result
    }
    
    func next(node: FixerNode, exclude: FixerNode) -> FixerNode {
        assert(!node.isStar)
        if node.data0 == exclude.index {
            return nodes[node.data1]
        } else {
            return nodes[node.data0]
        }
    }

    init(edges: [FixEdge]) {
        let n = edges.count
        
        var pMap = [Int64: Int]()
        pMap.reserveCapacity(n)

        var iEdges = [IxEdge](repeating: IxEdge(a: 0, b: 0), count: n)
        var points = [FixVec](repeating: .zero, count: n)
        
        var i = 0 // points count
        var j = 0 // edges count
        var eMap = [Int](repeating: 1, count: n)
        
        for edge in edges {
            let a: Int
            let b: Int
            
            if let ai = pMap[edge.e0.bitPack] {
                a = ai
                eMap[ai] = eMap[ai] + 1
            } else {
                a = i
                points[i] = edge.e0
                pMap[edge.e0.bitPack] = i
                i += 1
            }
            
            if let bi = pMap[edge.e1.bitPack] {
                b = bi
                eMap[bi] = eMap[bi] + 1
            } else {
                b = i
                points[i] = edge.e1
                pMap[edge.e1.bitPack] = i
                i += 1
            }
           
            iEdges[j] = IxEdge(a: a, b: b)
            j += 1
        }
        
        var nodes = [FixerNode](repeating: FixerNode(isStar: false, index: 0, data0: -1, data1: -1, point: .zero), count: i)
        
        var starsCount = 0
        for k in 0..<i {
            let cnt = eMap[k]
            assert(cnt > 1)
            if cnt > 2 {
                nodes[k] = FixerNode(isStar: true, index: k, data0: starsCount, data1: 0, point: points[k])
                starsCount += cnt
            } else {
                nodes[k] = FixerNode(isStar: false, index: k, data0: -1, data1: 0, point: points[k])
            }
        }
        
        var starIndices = [Int](repeating: 0, count: starsCount)

        for k in 0..<j {
            let edge = iEdges[k]
            
            var node = nodes[edge.a]

            if node.isStar {
                starIndices[node.data0 + node.data1] = edge.b
                node.data1 += 1
            } else {
                if node.data0 == -1 {
                    node.data0 = edge.b
                } else {
                    node.data1 = edge.b
                }
            }
            nodes[edge.a] = node

            node = nodes[edge.b]
            
            if node.isStar {
                starIndices[node.data0 + node.data1] = edge.a
                node.data1 += 1
            } else {
                if node.data0 == -1 {
                    node.data0 = edge.a
                } else {
                    node.data1 = edge.a
                }
            }
            nodes[edge.b] = node
            
        }

        self.nodes = nodes
        self.starIndices = starIndices
    }

}
