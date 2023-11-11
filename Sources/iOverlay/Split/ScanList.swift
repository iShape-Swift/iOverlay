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

    init(count: Int) {
        nodes = [Node](repeating: .empty, count: count)
        first = -1
    }

    func next(index: Int) -> Int {
        nodes[index].next
    }

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

    mutating func remove(index: Int) {
        guard index < nodes.count else {
            return
        }
        
        let node = nodes[index]

        guard node.isPresent else {
            return
        }
        
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
    
    mutating func clear() {
        for i in 0..<nodes.count {
            nodes[i] = .empty
        }
        first = -1
    }

    mutating func removeAllLessOrEqual(edge: ShapeEdge, list: EdgeLinkedList) {
        var sIndex = first
        
        // Try to intersect the current segment with all the segments in the scan list.
        while sIndex != -1 {
            let scanEdge = list.nodes[sIndex].edge
            if edge.isLessOrEqual(scanEdge) {
                sIndex = self.removeAndGetNext(index: sIndex)
                continue
            }
            sIndex = self.next(index: sIndex)
        }
    }
    
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
    
    mutating func validate(list: EdgeLinkedList) {
        var sIndex = first
        
        // Try to intersect the current segment with all the segments in the scan list.
        while sIndex != -1 {
            let scanEdge = list.nodes[sIndex].edge
            assert(scanEdge.a != scanEdge.b)
            sIndex = self.next(index: sIndex)
        }
    }
}


struct ScanList2 {
    
    private var items: [Int]
    
    var count: Int {
        items.count
    }
    
    subscript(index: Int) -> Int {
        items[index]
    }

    init(count: Int) {
        items = [Int]()
        let capacity = 2 * Int(Double(count).squareRoot())
        items.reserveCapacity(capacity)
    }

    mutating func add(index: Int) {
        guard !items.contains(where: { $0 == index }) else {
            return
        }
        items.append(index)
    }

    mutating func remove(index: Int) {
        guard let index = items.first(where: { $0 == index }) else {
            return
        }
        self.removeByReplace(index: index)
    }
    
    mutating func clear() {
        items.removeAll()
    }

    mutating func removeAllLessOrEqual(edge: ShapeEdge, list: EdgeLinkedList) {
        var i = 0
        while i < items.count {
            let item = items[i]
            let scanEdge = list.nodes[item].edge
            if edge.isLessOrEqual(scanEdge) {
                self.removeByReplace(index: item)
            } else {
                i += 1
            }
        }
    }

    mutating func validate(list: EdgeLinkedList) {
        for item in items {
            let scanEdge = list.nodes[item].edge
            assert(scanEdge.a != scanEdge.b)
        }
    }
    
    mutating func removeByReplace(index: Int) {
        if index + 1 < items.count {
            items[index] = items.removeLast()
        } else {
            items.removeLast()
        }
    }
    
}
