//
//  EdgeLinkedList.swift
//  
//
//  Created by Nail Sharipov on 05.08.2023.
//

import iShape
import iFixFloat

struct EdgeNode {
    static let empty = EdgeNode(next: -1, prev: -1, edge: .zero)

    var next: Int
    var prev: Int
    var edge: ShapeEdge
}


struct EdgeLinkedList {
    
    private var free: [Int]
    private (set) var nodes: [EdgeNode]
    private (set) var first: Int

    @inlinable
    var count: Int { nodes.count }

    @inlinable
    subscript(index: Int) -> ShapeEdge {
        @inlinable
        get {
            nodes[index].edge
        }
    }
    
    @inlinable
    init(edges: [ShapeEdge]) {
        let plusCapacity = 16
        nodes = [EdgeNode](repeating: .empty, count: edges.count + plusCapacity)
        free = [Int]()
        
        var i = 0
        while i < edges.count - 1 {
            nodes[i] = EdgeNode(next: i + 1, prev: i - 1, edge: edges[i])
            i += 1
        }
        nodes[i] = EdgeNode(next: -1, prev: i - 1, edge: edges[i])
        
        i = edges.count + plusCapacity - 1
        
        while i >= edges.count {
            free.append(i)
            nodes[i] = .empty
            i -= 1
        }
        
        first = 0
    }
    
    @inlinable
    func nextNode(index: Int) -> EdgeNode {
        nodes.withUnsafeBufferPointer({ buffer in
            let nextIndex = buffer[index].next
            if nextIndex != -1 {
                return buffer[nextIndex]
            } else {
                return .empty
            }
        })
    }
    
    @inlinable
    mutating func remove(index: Int) {
        let node = nodes[index]
        if node.prev != -1 {
            var prev = nodes[node.prev]
            prev.next = node.next
            nodes[node.prev] = prev
        } else {
            first = node.next
        }
        
        if node.next != -1 {
            var next = nodes[node.next]
            next.prev = node.prev
            nodes[node.next] = next
        }
        
        nodes[index] = .init(next: -1, prev: -1, edge: .zero)
        
        free.append(index)
    }

    @inlinable
    mutating func addAndMerge(anchorIndex: Int, newEdge: ShapeEdge) -> Int {
        if free.isEmpty {
            let newIndex = nodes.count
            nodes.append(EdgeNode(next: 0, prev: 0, edge: .zero))
            free.append(newIndex)
        }
        
        return nodes.withUnsafeMutableBufferPointer({ buffer in
            let anchor = buffer[anchorIndex]
            
            if newEdge.isLess(anchor.edge) {
                // search back
                var nextIx = anchorIndex
                var next = anchor
                var i = anchor.prev
                while i >= 0 {
                    var node = buffer[i]
                    if newEdge.isLess(node.edge) {
                        nextIx = i
                        next = node
                        i = node.prev
                    } else if node.edge.isEqual(newEdge) {
                        
                        // merge
                        
                        let count = node.edge.count.add(newEdge.count)
                        
                        node.edge = ShapeEdge(parent: newEdge, count: count)
                        buffer[i] = node
                        
                        return i
                    } else {
                        
                        // insert new
                        
                        let free = free.removeLast()
                        node.next = free
                        next.prev = free
                        buffer[i] = node
                        buffer[free] = EdgeNode(next: nextIx, prev: i, edge: newEdge)
                        buffer[nextIx] = next
                        
                        return free
                    }
                }
                
                // nothing is found
                // add as first

                let free = free.removeLast()
                first = free
                next.prev = free
                buffer[free] = EdgeNode(next: nextIx, prev: -1, edge: newEdge)
                buffer[nextIx] = next
                
                return free
            } else {
                // search forward
                var prevIx = anchorIndex
                var prev = anchor
                var i = anchor.next
                while i >= 0 {
                    var node = buffer[i]
                    if node.edge.isLess(newEdge) {
                        prevIx = i
                        prev = node
                        i = node.next
                    } else if node.edge.isEqual(newEdge) {
                        
                        // merge
                        
                        let count = node.edge.count.add(newEdge.count)

                        node.edge = ShapeEdge(parent: newEdge, count: count)
                        buffer[i] = node
                        
                        return i
                    } else {
                        
                        // insert new
                        
                        let free = free.removeLast()
                        node.prev = free
                        prev.next = free
                        buffer[i] = node
                        buffer[prevIx] = prev
                        buffer[free] = EdgeNode(next: i, prev: prevIx, edge: newEdge)
                        
                        return free
                    }
                }
                
                // nothing is found
                // add as last

                let free = free.removeLast()
                prev.next = free
                buffer[free] = EdgeNode(next: -1, prev: prevIx, edge: newEdge)
                buffer[prevIx] = prev
                
                return free
            }
            
        })
    }
    
    @inlinable
    func edges() -> [ShapeEdge] {
        var result = [ShapeEdge]()
        result.reserveCapacity(nodes.count)
        var index = first
        while index >= 0 {
            let node = nodes[index]
            
            if !node.edge.count.isEven {
                result.append(node.edge)
            }

            index = node.next
        }
        return result
    }
    
}
