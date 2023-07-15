//
//  PathList.swift
//  
//
//  Created by Nail Sharipov on 14.07.2023.
//

import iFixFloat
import iShape

private struct PathNode {
    var next: Int
    var prev: Int
    let point: FixVec
}

enum JoinResult {
    case single
    case close
    case skip
}


struct PathList {
    
    let parentId: Int
    private var nodes: [PathNode]
    private var next: Int
    private var prev: Int
    private let value: Int
    
    init(center: FixVec, next: FixVec, prev: FixVec, parentId: Int, value: Int) {
        nodes = [PathNode]()
        nodes.append(PathNode(next: 1, prev: 2, point: center))
        nodes.append(PathNode(next: -1, prev: 0, point: next))
        nodes.append(PathNode(next: 0, prev: -1, point: prev))

        self.next = 1
        self.prev = 2
        self.parentId = parentId
        self.value = value
    }
    
    mutating func join(start: FixVec, end: FixVec) {
        if start == nodes[next].point {
            self.addNext(start: start, end: end)
        } else if start == nodes[prev].point {
            self.addPrev(start: start, end: end)
        }
    }

    mutating func join(start: FixVec, ends: [FixVec]) {
        if start == nodes[next].point {
            self.addNext(start: start, end: ends[0])
        } else if start == nodes[prev].point {
            self.addPrev(start: start, end: ends[ends.count - 1])
        }
    }
    
    private mutating func addNext(start: FixVec, end: FixVec) {
        if end == nodes[prev].point {
            self.close(nextVec: start, prevVec: end)
        } else {
            self.addNext(start)
        }
    }

    private mutating func addPrev(start: FixVec, end: FixVec) {
        if end == nodes[next].point {
            self.close(nextVec: end, prevVec: start)
        } else {
            self.addPrev(start)
        }
    }
    
    private mutating func addNext(_ point: FixVec) {
        var nextNode = nodes[next]
        nextNode.next = nodes.count
        nodes[next] = nextNode
        
        nodes.append(PathNode(next: -1, prev: next, point: point))
        
        next = nextNode.next
    }

    private mutating func addPrev(_ point: FixVec) {
        var prevNode = nodes[prev]
        prevNode.prev = nodes.count
        nodes[prev] = prevNode
        
        nodes.append(PathNode(next: prev, prev: -1, point: point))
        
        prev = prevNode.prev
    }
 
    private mutating func close(nextVec: FixVec, prevVec: FixVec) {
        let newNext = nodes.count
        let newPrev = newNext + 1
        
        var nextNode = nodes[next]
        nextNode.next = newNext
        nodes[next] = nextNode

        var prevNode = nodes[prev]
        prevNode.prev = newPrev
        nodes[prev] = prevNode
        
        nodes.append(PathNode(next: newPrev, prev: next, point: nextVec))
        nodes.append(PathNode(next: newNext, prev: prev, point: prevVec))
        
        next = newNext
        prev = newPrev
    }
    
    func isContain(_ point: FixVec) -> Bool {
        if nodes.count == 4 {
            let nextNode = nodes[next]
            let a0 = nodes[nextNode.prev].point
            let a1 = nextNode.point

            let prevNode = nodes[prev]
            let b0 = nodes[prevNode.next].point
            let b1 = prevNode.point
            
            return Self.isContain(point: point, a0: a0, a1: a1, b0: b0, b1: b1)
        } else {
            // polygon has at least 3 nodes
            let p0 = nodes[0].point
            let p1 = nodes[1].point
            let p2 = nodes[2].point
            return Triangle.isContain(p: point, p0: p0, p1: p1, p2: p2)
        }
    }
    
    private static func isContain(point: FixVec, a0: FixVec, a1: FixVec, b0: FixVec, b1: FixVec) -> Bool {
        let sa = (a1 - a0).unsafeCrossProduct(point - a0)
        let sb = (b1 - b0).unsafeCrossProduct(point - b0)
        
        return sa <= 0 && sb >= 0
    }
    
}
