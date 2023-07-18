//
//  SPath.swift
//  
//
//  Created by Nail Sharipov on 14.07.2023.
//

import iFixFloat
import iShape

private struct SPathNode {
    var next: Int
    var prev: Int
    let vIndex: Int
}

enum JoinResult {
    case single
    case close
    case skip
}

struct SPath {
    
    let parentId: Int
    private var nodes: [SPathNode]
    private var next: Int
    private var prev: Int
    private let value: Int
    
    private var next_0: FixVec
    private var next_1: FixVec
    private var prev_0: FixVec
    private var prev_1: FixVec
    
    init(center: IndexPoint, next: IndexPoint, prev: IndexPoint, parentId: Int, value: Int) {
        nodes = [SPathNode]()
        nodes.append(SPathNode(next: 1, prev: 2, vIndex: center.index))
        nodes.append(SPathNode(next: -1, prev: 0, vIndex: next.index))
        nodes.append(SPathNode(next: 0, prev: -1, vIndex: prev.index))

        next_0 = center.point
        next_1 = next.point

        prev_0 = center.point
        prev_1 = prev.point
        
        self.next = 1
        self.prev = 2
        self.parentId = parentId
        self.value = value
    }
    
    mutating func join(start: IndexPoint, end: IndexPoint) -> JoinResult {
        if start.index == nodes[next].vIndex {
            return self.addNext(start: start, end: end)
        } else if start.index == nodes[prev].vIndex {
            return self.addPrev(start: start, end: end)
        } else {
            return .skip
        }
    }

    mutating func join(start: IndexPoint, firstEnd: IndexPoint, lastEnd: IndexPoint) -> JoinResult {
        if start.index == nodes[next].vIndex {
            return self.addNext(start: start, end: firstEnd)
        } else if start.index == nodes[prev].vIndex {
            return self.addPrev(start: start, end: lastEnd)
        } else {
            return .skip
        }
    }
    
    private mutating func addNext(start: IndexPoint, end: IndexPoint) -> JoinResult {
        if end.index == nodes[prev].vIndex {
            self.close(nextVec: start, prevIndex: end.index)
            return .close
        } else {
            self.addNext(start)
            return .single
        }
    }

    private mutating func addPrev(start: IndexPoint, end: IndexPoint) -> JoinResult {
        if end.index == nodes[next].vIndex {
            self.close(nextVec: end, prevIndex: start.index)
            return .close
        } else {
            self.addPrev(start)
            return .single
        }
    }
    
    private mutating func addNext(_ vert: IndexPoint) {
        next_0 = next_1
        next_1 = vert.point
        var nextNode = nodes[next]
        nextNode.next = nodes.count
        nodes[next] = nextNode
        
        nodes.append(SPathNode(next: -1, prev: next, vIndex: vert.index))
        
        next = nextNode.next
    }

    private mutating func addPrev(_ vert: IndexPoint) {
        prev_0 = prev_1
        prev_1 = vert.point
        var prevNode = nodes[prev]
        prevNode.prev = nodes.count
        nodes[prev] = prevNode
        
        nodes.append(SPathNode(next: prev, prev: -1, vIndex: vert.index))
        
        prev = prevNode.prev
    }
 
    private mutating func close(nextVec: IndexPoint, prevIndex: Int) {
        let newNext = nodes.count
        let newPrev = newNext + 1
        
        var nextNode = nodes[next]
        nextNode.next = newNext
        nodes[next] = nextNode

        var prevNode = nodes[prev]
        prevNode.prev = newPrev
        nodes[prev] = prevNode
        
        nodes.append(SPathNode(next: newPrev, prev: next, vIndex: nextVec.index))
        nodes.append(SPathNode(next: newNext, prev: prev, vIndex: prevIndex))
        
        next = newNext
        prev = newPrev
    }
    
    func isContain(_ point: FixVec) -> Bool {
        if nodes.count == 4 {
            return Self.isContain(point: point, a0: next_0, a1: next_1, b0: prev_0, b1: prev_1)
        } else {
            // polygon has at least 3 nodes (next_0 === prev_0)
            return Triangle.isContain(p: point, p0: next_1, p1: next_0, p2: prev_1)
        }
    }
    
    private static func isContain(point: FixVec, a0: FixVec, a1: FixVec, b0: FixVec, b1: FixVec) -> Bool {
        let sa = (a1 - a0).unsafeCrossProduct(point - a0)
        let sb = (b1 - b0).unsafeCrossProduct(point - b0)
        
        return sa <= 0 && sb >= 0
    }
    
}
