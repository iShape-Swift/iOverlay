//
//  LinkedList.swift
//  
//
//  Created by Nail Sharipov on 24.07.2023.
//


struct LinkedListNode {
    var next: Int
    var prev: Int
}

struct LinkedList {
    
    private (set) var nodes: [LinkedListNode]

    @inlinable
    subscript(_ index: Int) -> LinkedListNode {
        get {
            nodes[index]
        }
        
        set {
            nodes[index] = newValue
        }
    }
    
    @inlinable
    init(count: Int) {
        nodes = [LinkedListNode](repeating: .init(next: -1, prev: -1), count: count)
    }

    @inlinable
    mutating func join(next: Int, index: Int, prev: Int) {
        var nIndex = nodes[index]
        
        var nNext = nodes[next]
        var nPrev = nodes[prev]
        nNext.next = index
        nPrev.prev = index
        
        nIndex.prev = next
        nIndex.next = prev
        
        nodes[next] = nNext
        nodes[prev] = nPrev
        nodes[index] = nIndex
    }
    
    @inlinable
    mutating func join(next: Int, index: Int) {
        var nIndex = nodes[index]
        
        var nNext = nodes[next]
        nNext.next = index
        
        nIndex.prev = next
        nIndex.next = -1
        
        nodes[next] = nNext
        nodes[index] = nIndex
    }

    @inlinable
    mutating func join(prev: Int, index: Int) {
        var nIndex = nodes[index]
        
        var nPrev = nodes[prev]
        nPrev.prev = index
        
        nIndex.prev = -1
        nIndex.next = prev

        nodes[prev] = nPrev
        nodes[index] = nIndex
    }

    @inlinable
    mutating func join(next: Int, prev: Int) {
        var nNext = nodes[next]
        nNext.prev = prev
        nodes[next] = nNext
        
        var nPrev = nodes[prev]
        nPrev.next = next
        nodes[prev] = nPrev
    }
    
    @inlinable
    mutating func addToNext(_ next: Int, index: Int) {
        var nNext = nodes[next]
        nNext.next = index
        nodes[next] = nNext
        
        var node = nodes[index]
        node.prev = next
        nodes[index] = node
    }
    
    mutating func invert(oldNext: Int, oldPrev: Int) {
        var j = -1
        var i = oldNext
        while j != oldPrev {
            var n = self[i]

            j = i
            i = n.prev

            n.invert()
            
            self[j] = n
        }
    }
    
    mutating func invert(oldPrev: Int, oldNext: Int) {
        var j = -1
        var i = oldPrev
        while j != oldNext {
            var n = self[i]

            j = i
            i = n.next

            n.invert()
            
            self[j] = n
        }
    }

}

private extension LinkedListNode {

    mutating func invert() {
        let oldPrev = prev
        self.prev = next
        self.next = oldPrev
    }

}
