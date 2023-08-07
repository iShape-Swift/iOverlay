//
//  File.swift
//  
//
//  Created by Nail Sharipov on 06.08.2023.
//

import iShape
import iFixFloat

struct SNode {
    static let empty = SNode(next: -1, prev: -1, isPresent: false)
    
    var next: Int
    var prev: Int
    var isPresent: Bool
}


struct SList {
    
    private var list: [SNode]
    private (set) var first: Int
    
    init(count: Int) {
        list = [SNode](repeating: .empty, count: count)
        first = -1
    }
    
    func next(index: Int) -> Int {
        list[index].next
    }
    
    mutating func add(index: Int) {
        guard index != -1 else {
            return
        }

        if index >= list.count {
            self.increase(index: index)
        }
        
        guard !list[index].isPresent else {
            return
        }
        
        guard first != -1 else {
            first = index
            list[index] = SNode(next: -1, prev: -1, isPresent: true)
            return
        }
        
        var next = list[first]
        next.prev = index
        list[first] = next
        
        list[index] = SNode(next: first, prev: -1, isPresent: true)

        first = index
    }
    
    mutating func remove(index: Int) {
        let node = list[index]

        if node.prev != -1 {
            var prev = list[node.prev]
            prev.next = node.next
            list[node.prev] = prev
        }
        
        if node.next != -1 {
            var next = list[node.next]
            next.prev = node.prev
            list[node.next] = next
        }
        
        if first == index {
            first = node.next
        }
        
        list[index] = .empty
    }
    
    private mutating func increase(index: Int) {
        while list.count <= index {
            list.append(.empty)
        }
    }
    
    mutating func clear() {
        for i in 0..<list.count {
            list[i] = .empty
        }
        first = -1
    }
    
    mutating func removeAllLessOrEqual(edge: ShapeEdge, list: EdgeList) {
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
    
    mutating func removeAndGetNext(index: Int) -> Int {
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
        
        if first == index {
            first = node.next
        }
        
        list[index] = .empty
        
        return node.next
    }
}
