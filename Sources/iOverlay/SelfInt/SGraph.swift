//
//  SGraph.swift
//  
//
//  Created by Nail Sharipov on 14.07.2023.
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

public struct SGraph {

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
        let nodeRes = Self.nodes(handles: handles, conRes: conRes)
        
        self.links = nodeRes.links
        self.nodes = nodeRes.nodes
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
    
    private struct ConRes {
        let verts: [FixVec]
        let cons: [Connection]
    }
    
    private static func connections(handles: [Handle]) -> ConRes {
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
        
        return ConRes(verts: verts, cons: cons)
    }
    
    private struct NodeRes {
        let links: [GraphLink]
        let nodes: [GraphNode]
    }
    
    private static func nodes(handles: [Handle], conRes: ConRes) -> NodeRes {
        var links = [GraphLink]()
        links.reserveCapacity(conRes.cons.count)
        
        var nodes = [GraphNode](repeating: .init(offset: 0, count: 0), count: conRes.verts.count)

        var iMap = IntMap(maxValue: conRes.verts.count - 1)
        
        var j = 0
        var i = 0
        var offset = 0
        while j < conRes.verts.count {
            let v = conRes.verts[j]
            
            var h = handles[i]
            while h.vec == v {
                let con = conRes.cons[h.segId]
                if h.isStart {
                    iMap[con.b] = iMap.get(key: con.b, def: 0) + 1
                } else {
                    iMap[con.a] = iMap.get(key: con.a, def: 0) - 1
                }

                i += 1
                if i >= handles.count {
                    break
                }
                h = handles[i]
            }
            // new round
            
            var n = 0
            for key in iMap.keys {
                let power = iMap[key]
                if power > 0 {
                    n += 1
                    links.append(GraphLink(nodeIndex: key, power: power))
                }
            }

            nodes[j] = GraphNode(offset: offset, count: n)
            offset += n
            
            iMap.removeAll()

            j += 1
        }
        
        return NodeRes(links: links, nodes: nodes)
        
    }
    
}
