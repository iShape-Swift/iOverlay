//
//  SegmentGraph.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat

private struct Handle {
    let segId: Int
    let vec: FixVec
    let isStart: Bool
}

private struct Connection {
    var a: Int
    var b: Int
}

public struct GraphNode {
    public let offset: Int
    public let count: Int
}

public struct GraphLink {
    public let nodeIndex: Int
    public let power: Int
}

public struct SegmentGraph {

    public let links: [GraphLink]
    public let nodes: [GraphNode]
    public let verts: [FixVec]
    
    init(segments: [Segment]) {
        guard !segments.isEmpty else {
            links = []
            nodes = []
            verts = []
            return
        }

        let handles = Self.handles(segments: segments)
        let conRes = Self.connections(handles: handles)
        
        var links = [GraphLink]()
        var nodes = [GraphNode](repeating: .init(offset: 0, count: 0), count: conRes.verts.count)

        var iMap = IntMap(maxValue: conRes.verts.count - 1)
        var i = 0
        var vi = 0 // vert index
        var offset = 0
        var cnt = 0
        var v0 = handles[0].vec
        while i < handles.count {
            let h = handles[i]
            if v0 != h.vec {
                // new round
                cnt = 0
                for key in iMap.keys {
                    let power = iMap[key]
                    if power > 0 {
                        cnt += 1
                        links.append(GraphLink(nodeIndex: key, power: power))
                    }
                }

                nodes[vi] = GraphNode(offset: offset, count: cnt)
                offset += cnt
                
                iMap.removeAll()
                vi += 1
                v0 = h.vec
            }

            let con = conRes.cons[h.segId]
            if h.isStart {
                iMap[con.b] += 1
            } else {
                iMap[con.a] -= 1
            }

            i += 1
        }
        
        // set last node
        cnt = 0
        for key in iMap.keys {
            let power = iMap[key]
            if power > 0 {
                cnt += 1
                links.append(GraphLink(nodeIndex: key, power: power))
            }
        }

        nodes[nodes.count - 1] = GraphNode(offset: offset, count: cnt)
        
        self.links = links
        self.nodes = nodes
        self.verts = conRes.verts
    }
    
    
    private static func handles(segments: [Segment]) -> [Handle] {
        let n = 2 * segments.count
        var handles = [Handle](repeating: .init(segId: 0, vec: .zero, isStart: false), count: n)

        var j = 0
        for i in 0..<segments.count {
            let s = segments[i]
            
            handles[j] = Handle(segId: i, vec: s.a, isStart: s.isDirect)
            j += 1
            
            handles[j] = Handle(segId: i, vec: s.b, isStart: !s.isDirect)
            j += 1
        }
        
        handles.sort(by: { $0.vec.bitPack < $1.vec.bitPack })
        
        return handles
    }
    
    private struct ConResult {
        let verts: [FixVec]
        let cons: [Connection]
    }
    
    private static func connections(handles: [Handle]) -> ConResult {
        var verts = [FixVec]()
        var cons = [Connection](repeating: Connection(a: 0, b: 0), count: handles.count / 2)

        var v0 = handles[0].vec
        var vi = 0
        verts.append(v0)
        
        var i = 0
        while i < handles.count {
            let h = handles[i]
            if v0 != h.vec {
                verts.append(h.vec)
                v0 = h.vec
                vi += 1
            }
            
            var con = cons[h.segId]
            if h.isStart {
                con.a = vi
            } else {
                con.b = vi
            }
            cons[h.segId] = con
            
            i += 1
        }
        
        return ConResult(verts: verts, cons: cons)
    }
    
}
