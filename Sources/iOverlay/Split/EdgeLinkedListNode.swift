//
//  EdgeLinkedListNode.swift
//
//
//  Created by Nail Sharipov on 22.11.2023.
//

let emptyIndex: UInt32 = .max

struct EdgeLinkedListNode {

    static let empty: EdgeLinkedListNode = EdgeLinkedListNode(
        next: emptyIndex,
        prev: emptyIndex,
        edge: .zero
    )
    
    var next: UInt32
    var prev: UInt32
    var edge: ShapeEdge
    
    var isRemoved: Bool {
        edge.count.isEven
    }

}

struct EdgeLinkedList {
    
    private var free: [UInt32]
    var nodes: [EdgeLinkedListNode]
    private (set) var firstIndex: UInt32
    
    var count: Int { nodes.count }
    
    init(edges: ArraySlice<ShapeEdge>) {
        nodes = [EdgeLinkedListNode]()
        
        let capacity = edges.count + 16
        nodes.reserveCapacity(capacity)
        
        var index: UInt32 = 0
        for edge in edges {
            let node = EdgeLinkedListNode(next: index + 1, prev: index &- 1, edge: edge)
            nodes.append(node)
            index += 1
        }
        nodes[edges.count - 1].next = emptyIndex
        
        let n = UInt32(nodes.count)
        var i = UInt32(capacity - 1)
        free = [UInt32]()
        free.reserveCapacity(capacity - nodes.count)
        
        while i >= n {
            free.append(i)
            nodes.append(EdgeLinkedListNode.empty)
            i -= 1
        }
        
        firstIndex = 0
    }
    
    mutating func remove(index: UInt32) {
        let node = nodes[Int(index)]
        
        if node.prev != emptyIndex {
            var prev = nodes[Int(node.prev)]
            prev.next = node.next
            nodes[Int(node.prev)] = prev
        } else {
            firstIndex = node.next
        }
        
        if node.next != emptyIndex {
            var next = nodes[Int(node.next)]
            next.prev = node.prev
            nodes[Int(node.next)] = next
        }
        
        nodes[Int(index)] = .empty
        
        free.append(index)
    }

    mutating func update(index: UInt32, edge: ShapeEdge) {
        self.nodes[Int(index)].edge = edge
    }
    
    mutating func findFromStart(edge: ShapeEdge) -> UInt32 {
        if firstIndex != emptyIndex {
            let first = self.nodes[Int(firstIndex)]
            if first.edge.isEqual(edge) {
                return firstIndex
            } else if edge.isLess(first.edge) {
                let oldFirst = firstIndex
                firstIndex = self.anyFree()
                self.nodes[Int(oldFirst)].prev = firstIndex
                self.nodes[Int(firstIndex)].next = oldFirst
                return firstIndex
            } else {
                return self.findForward(fromIndex: firstIndex, edge: edge)
            }
        } else {
            firstIndex = self.anyFree()
            return firstIndex
        }
    }
    
    private mutating func findBack(fromIndex: UInt32, edge: ShapeEdge) -> UInt32 {
        var nextIndex = fromIndex
        var next = nodes[Int(nextIndex)]
        
        assert(!next.isRemoved)
        
        while next.prev != emptyIndex {
            let prevIndex = next.prev
            var prev = nodes[Int(prevIndex)]
            if prev.edge.isEqual(edge) {
                return prevIndex
            } else if prev.edge.isLess(edge) {
                // insert new
                let newIndex = self.anyFree()
                var newNode = EdgeLinkedListNode.empty
                
                prev.next = newIndex
                next.prev = newIndex
                
                newNode.next = nextIndex
                newNode.prev = prevIndex
                
                nodes[Int(prevIndex)] = prev
                nodes[Int(newIndex)] = newNode
                nodes[Int(nextIndex)] = next
                
                return newIndex
            }
            
            nextIndex = prevIndex
            next = prev
        }

        // insert new as first
        let newIndex = self.anyFree()
        var newNode = EdgeLinkedListNode.empty
        
        firstIndex = newIndex
        next.prev = newIndex
        
        newNode.next = nextIndex
        
        nodes[Int(newIndex)] = newNode
        nodes[Int(nextIndex)] = next
        
        return newIndex
    }

    private mutating func findForward(fromIndex: UInt32, edge: ShapeEdge) -> UInt32 {
        var prev = nodes[Int(fromIndex)]
        var prevIndex = fromIndex

        assert(!prev.isRemoved)
        
        while prev.next != emptyIndex {
            let nextIndex = prev.next
            var next = nodes[Int(nextIndex)]
            if next.edge.isEqual(edge) {
                return nextIndex
            } else if edge.isLess(next.edge) {
                // insert new
                let newIndex = self.anyFree()
                var newNode = EdgeLinkedListNode.empty
                
                prev.next = newIndex
                next.prev = newIndex
                
                newNode.next = nextIndex
                newNode.prev = prevIndex
                
                nodes[Int(prevIndex)] = prev
                nodes[Int(newIndex)] = newNode
                nodes[Int(nextIndex)] = next
                
                return newIndex
            }
            
            prevIndex = nextIndex
            prev = next
            if prev.edge.isEqual(edge) {
                return fromIndex
            }
        }
        
        // insert new as last
        let newIndex = self.anyFree()
        var newNode = EdgeLinkedListNode.empty
        
        prev.next = newIndex
        
        newNode.prev = prevIndex

        nodes[Int(prevIndex)] = prev
        nodes[Int(newIndex)] = newNode

        return newIndex
    }
    
    mutating func find(anchorIndex: UInt32, edge: ShapeEdge) -> UInt32 {
        let anchor = self.nodes[Int(anchorIndex)]
        guard !anchor.isRemoved else {
            return self.findFromStart(edge: edge)
        }

        if edge.isEqual(anchor.edge) {
            return anchorIndex
        } else if edge.isLess(anchor.edge) {
            return findBack(fromIndex: anchorIndex, edge: edge)
        } else {
            return findForward(fromIndex: anchorIndex, edge: edge)
        }
    }

    private mutating func anyFree() -> UInt32 {
        if free.isEmpty {
            let newIndex = nodes.count
            nodes.append(EdgeLinkedListNode.empty)
            return UInt32(newIndex)
        } else {
            return free.removeLast()
        }
    }
}
