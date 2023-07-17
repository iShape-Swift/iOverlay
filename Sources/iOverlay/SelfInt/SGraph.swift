//
//  SGraph.swift
//  
//
//  Created by Nail Sharipov on 14.07.2023.
//

import iFixFloat
import iShape

private struct VConter {
    let vert: Int
    let count: Int
}

private struct VPntCnt {
    let index: Int
    let count: Int
    let point: FixVec
}

public struct Pointer {
    public let linkId: Int
    public let vIndex: Int
    public let count: Int // is positive it's direct else it's reverse
}

struct Link {
    var left: Int
    var right: Int
}

public struct DeepIndex {
    public let index: Int      // index in pointer array
    public let count: Int      // length of direct points in Pointer offset..<offset + directCount
}

public struct SGraph {
    
    public let verts: [FixVec]
    public let dir: [Pointer]
    public let dirIndex: [DeepIndex]
    
//    let all: [Pointer]
    
    init(segments: [Segment], vertices: [FixVec]) {
        let n = vertices.count
        
        // collect how many direct links from this vertex
        var verDirCnt = [Int](repeating: 0, count: n)
        
        for seg in segments {
            verDirCnt[seg.a.index] += 1
        }
        
        var offset = [Int](repeating: 0, count: n)
        var s = 0
        for i in 0..<n {
            offset[i] = s
            s += verDirCnt[i]
        }

        var vCnt = [VConter](repeating: VConter(vert: -1, count: 0), count: s)
        
        for seg in segments {
            let a = seg.a.index
            let b = seg.b.index
            let aStart = offset[a]
            let aLength = verDirCnt[a]
            let inc = seg.isDirect ? 1 : -1
            vCnt.add(start: aStart, length: aLength, vert: b, inc: inc)
        }

        var dir = [Pointer]()
        dir.reserveCapacity(s)
        
        var dirIndex = [DeepIndex](repeating: .init(index: 0, count: 0), count: n)
        var vPntCnt = [VPntCnt]()
        vPntCnt.reserveCapacity(8)
        var index = 0
        for a in 0..<n {
            let aStart = offset[a]
            let aEnd = aStart + verDirCnt[a]
            var j = aStart
            vPntCnt.removeAll(keepingCapacity: true)
            while j < aEnd {
                let v = vCnt[j]
                if v.count != 0 {
                    vPntCnt.append(VPntCnt(index: v.vert, count: v.count, point: vertices[v.vert]))
                }
                j += 1
            }
            
            if vPntCnt.count != 0 {
                vPntCnt.sort(start: vertices[a])
            }
            
            dirIndex[a] = DeepIndex(index: index, count: vPntCnt.count)
            for v in vPntCnt {
                let linkId = dir.count
                dir.append(Pointer(linkId: linkId, vIndex: v.index, count: v.count))
            }
            
            index += vPntCnt.count
        }

        self.verts = vertices
        self.dir = dir
        self.dirIndex = dirIndex
    }

}

private extension Array where Element == VConter {

    mutating func add(start: Int, length: Int, vert: Int, inc: Int) {
        var i = start
        let end = start + length
        while i < end {
            let v = self[i]
            if v.vert == -1 {
                self[i] = VConter(vert: vert, count: inc)
                return
            } else if v.vert == vert {
                self[i] = VConter(vert: vert, count: v.count + inc)
                return
            }
            i += 1
        }
    }
}

private extension Array where Element == VPntCnt {

    mutating func sort(start: FixVec) {
        self.sort(by: {
            if $0.point.x == $1.point.x {
                return $0.point.y < $1.point.y
            } else {
                return Triangle.isClockwise(p0: start, p1: $1.point, p2: $0.point)
            }
        })
    }
}
