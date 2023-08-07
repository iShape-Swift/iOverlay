//
//  EdgeList.swift
//  
//
//  Created by Nail Sharipov on 05.08.2023.
//

import iShape
import iFixFloat

struct EdgeNode {
    static let empty = EdgeNode(next: -1, prev: -1, index: -1, edge: .zero)

    var next: Int
    var prev: Int
    let index: Int
    var edge: ShapeEdge
}


struct EdgeList {
    
    private var free: [Int]
    private (set) var list: [EdgeNode]
    private (set) var first: Int

    var count: Int { list.count }

    subscript(index: Int) -> ShapeEdge {
        get {
            list[index].edge
        }
    }
    
    init(edges: [ShapeEdge]) {
        let plusCapacity = 16
        list = [EdgeNode](repeating: .empty, count: edges.count + plusCapacity)
        free = [Int]()
        
        var i = 0
        while i < edges.count - 1 {
            list[i] = EdgeNode(next: i + 1, prev: i - 1, index: i, edge: edges[i])
            i += 1
        }
        list[i] = EdgeNode(next: -1, prev: i - 1, index: i, edge: edges[i])
        
        i = edges.count + plusCapacity - 1
        
        while i >= edges.count {
            free.append(i)
            list[i] = .empty
            i -= 1
        }
        
        first = 0
    }
    
    func nextNode(index: Int) -> EdgeNode {
        let nextIndex = list[index].next
        if nextIndex != -1 {
            return list[nextIndex]
        } else {
            return .empty
        }
    }
    
    mutating func remove(index: Int) {
        let node = list[index]
        if node.prev != -1 {
            var prev = list[node.prev]
            prev.next = node.next
            list[node.prev] = prev
        } else {
            first = node.next
        }
        
        if node.next != -1 {
            var next = list[node.next]
            next.prev = node.prev
            list[node.next] = next
        }
        
        list[index] = .init(next: -1, prev: -1, index: index, edge: .zero)
        
        free.append(index)
    }

    private mutating func getFreeIndex() -> Int {
        guard free.isEmpty else {
            return free.removeLast()
        }
        let newIndex = list.count
        list.append(EdgeNode(next: 0, prev: 0, index: newIndex, edge: .zero))
        
        return newIndex
    }
    
    mutating func addAndMerge(anchorIndex: Int, edge: ShapeEdge) -> Int {
        let anchor = list[anchorIndex]
        
        if edge.isLess(anchor.edge) {
            // search back
            var nextIx = anchorIndex
            var next = anchor
            var i = anchor.prev
            while i >= 0 {
                var node = list[i]
                if edge.isLess(node.edge) {
                    nextIx = i
                    next = node
                    i = node.prev
                } else if node.edge.isEqual(edge) {
                    
                    // merge
                    
                    let count = edge.count.add(edge.count)
                    node.edge = ShapeEdge(parent: edge, count: count)
                    list[i] = node
                    
                    return i
                } else {
                    
                    // insert new
                    
                    let free = getFreeIndex()
                    node.next = free
                    next.prev = free
                    list[i] = node
                    list[free] = EdgeNode(next: nextIx, prev: i, index: free, edge: edge)
                    list[nextIx] = next
                    
                    return free
                }
            }
            
            // nothing is found
            // add as first

            let free = getFreeIndex()
            first = free
            next.prev = free
            list[free] = EdgeNode(next: nextIx, prev: -1, index: free, edge: edge)
            list[nextIx] = next
            
            return free
        } else {
            // search forward
            var prevIx = anchorIndex
            var prev = anchor
            var i = anchor.next
            while i >= 0 {
                var node = list[i]
                if node.edge.isLess(edge) {
                    prevIx = i
                    prev = node
                    i = node.next
                } else if node.edge.isEqual(edge) {
                    
                    // merge
                    
                    let count = edge.count.add(edge.count)
                    node.edge = ShapeEdge(parent: edge, count: count)
                    list[i] = node
                    
                    return i
                } else {
                    
                    // insert new
                    
                    let free = getFreeIndex()
                    node.prev = free
                    prev.next = free
                    list[i] = node
                    list[prevIx] = prev
                    list[free] = EdgeNode(next: i, prev: prevIx, index: free, edge: edge)
                    
                    return free
                }
            }
            
            // nothing is found
            // add as last

            let free = getFreeIndex()
            prev.next = free
            list[free] = EdgeNode(next: -1, prev: prevIx, index: free, edge: edge)
            list[prevIx] = prev
            
            return free
        }
    }
    
    func edges() -> [ShapeEdge] {
        var result = [ShapeEdge]()
        result.reserveCapacity(list.count)
        var index = first
        while index >= 0 {
            let node = list[index]
            result.append(node.edge)
            index = node.next
        }
        return result
    }
    
}
