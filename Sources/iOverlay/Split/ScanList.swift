//
//  ScanList.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iShape
import iFixFloat

private struct Node {
    static let empty = Node(next: -1, prev: -1, isPresent: false)
    
    var next: Int
    var prev: Int
    var isPresent: Bool
}

struct ScanList {
    
    private var nodes: [Node]
    private (set) var first: Int
    
    @inlinable
    init(count: Int) {
        nodes = [Node](repeating: .empty, count: count)
        first = -1
    }
    
    @inlinable
    func next(index: Int) -> Int {
        nodes[index].next
    }
    
    @inlinable
    mutating func add(index: Int) {
        guard index != -1 else {
            return
        }

        if index >= nodes.count {
            self.increase(index: index)
        }
        
        guard !nodes[index].isPresent else {
            return
        }
        
        guard first != -1 else {
            first = index
            nodes[index] = Node(next: -1, prev: -1, isPresent: true)
            return
        }
        
        var next = nodes[first]
        next.prev = index
        nodes[first] = next
        
        nodes[index] = Node(next: first, prev: -1, isPresent: true)

        first = index
    }
    
    @inlinable
    mutating func remove(index: Int) {
        let node = nodes[index]

        if node.prev != -1 {
            var prev = nodes[node.prev]
            prev.next = node.next
            nodes[node.prev] = prev
        }
        
        if node.next != -1 {
            var next = nodes[node.next]
            next.prev = node.prev
            nodes[node.next] = next
        }
        
        if first == index {
            first = node.next
        }
        
        nodes[index] = .empty
    }
    
    private mutating func increase(index: Int) {
        while nodes.count <= index {
            nodes.append(.empty)
        }
    }
    
    @inlinable
    mutating func clear() {
        for i in 0..<nodes.count {
            nodes[i] = .empty
        }
        first = -1
    }
    
    @inlinable
    mutating func removeAllLessOrEqual(edge: ShapeEdge, list: EdgeLinkedList) {
        var sIndex = first
        
        // Try to intersect the current segment with all the segments in the scan list.
        while sIndex != -1 {
            let scanEdge = list[sIndex]
            if edge.isLessOrEqual(scanEdge) {
                sIndex = self.removeAndGetNext(index: sIndex)
                continue
            }
            sIndex = self.next(index: sIndex)
        }
    }
    
    @inlinable
    mutating func removeAndGetNext(index: Int) -> Int {
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
        
        if first == index {
            first = node.next
        }
        
        nodes[index] = .empty
        
        return node.next
    }
}
