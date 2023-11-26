//
//  EdgeLinkedListNode.swift
//
//
//  Created by Nail Sharipov on 22.11.2023.
//

let emptyIndex: UInt32 = .max

struct EdgeLinkedListNode {
    fileprivate (set) var next: UInt32
    fileprivate var prev: UInt32
    fileprivate (set) var edge: ShapeEdge
    
    @inline(__always)
    var isRemoved: Bool {
        edge.count.isEven
    }
    
    @inline(__always)
    fileprivate mutating func clear() {
        next = emptyIndex
        prev = emptyIndex
        edge = .zero
    }

}

struct EdgeLinkedList {
    
    private var free: [UInt32]
    private (set) var nodes: [EdgeLinkedListNode]
    private (set) var firstIndex: UInt32
    
    var count: Int { nodes.count }
    
    init(edges: ArraySlice<ShapeEdge>) {
        nodes = [EdgeLinkedListNode]()
        
        let extraCapacity = min(16, edges.count / 2)
        
        let capacity = edges.count + extraCapacity
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
            nodes.append(EdgeLinkedListNode(next: emptyIndex, prev: emptyIndex, edge: .zero))
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
        
        nodes[Int(index)].clear()
        
        free.append(index)
    }

    mutating func update(index: UInt32, edge: ShapeEdge) {
        self.nodes[Int(index)].edge = edge
    }
    
    mutating func update(index: UInt32, count: ShapeCount) {
        self.nodes[Int(index)].edge.count = count
    }
    
    mutating func findFromStart(edge: ShapeEdge) -> UInt32 {
        if firstIndex != emptyIndex {
            let firstEdge = self.nodes[Int(firstIndex)].edge
            if firstEdge.isEqual(edge) {
                return firstIndex
            } else if edge.isLess(firstEdge) {
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
        var nodePrev = nodes[Int(fromIndex)].prev
        var nextIndex = fromIndex

        while nodePrev != emptyIndex {
            let prevEdge = nodes[Int(nodePrev)].edge
            if prevEdge.isLess(edge) {
                // insert new
                let newIndex = self.anyFree()
                
                nodes[Int(nodePrev)].next = newIndex
                nodes[Int(newIndex)].next = nextIndex
                nodes[Int(newIndex)].prev = nodePrev
                nodes[Int(nextIndex)].prev = newIndex
                
                return newIndex
            } else if prevEdge.isEqual(edge) {
                return nodePrev
            }
            
            nextIndex = nodePrev
            nodePrev = nodes[Int(nodePrev)].prev
        }

        // insert new as first
        firstIndex = self.anyFree()
        
        nodes[Int(firstIndex)].next = nextIndex
        nodes[Int(nextIndex)].prev = firstIndex
        
        return firstIndex
    }

    private mutating func findForward(fromIndex: UInt32, edge: ShapeEdge) -> UInt32 {
        var prevNext = nodes[Int(fromIndex)].next
        var prevIndex = fromIndex
        
        while prevNext != emptyIndex {
            let nextIndex = prevNext
            let nextEdge = nodes[Int(nextIndex)].edge
            if edge.isLess(nextEdge) {
                // insert new
                let newIndex = self.anyFree()
                
                nodes[Int(prevIndex)].next = newIndex
                nodes[Int(newIndex)].next = nextIndex
                nodes[Int(newIndex)].prev = prevIndex
                nodes[Int(nextIndex)].prev = newIndex
                
                return newIndex
            } else if nextEdge.isEqual(edge) {
                return nextIndex
            }
            
            prevIndex = nextIndex
            prevNext = nodes[Int(nextIndex)].next
        }
        
        // insert new as last
        let newIndex = self.anyFree()

        nodes[Int(prevIndex)].next = newIndex
        nodes[Int(newIndex)].prev = prevIndex

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
            nodes.append(EdgeLinkedListNode(next: emptyIndex, prev: emptyIndex, edge: .zero))
            return UInt32(newIndex)
        } else {
            return free.removeLast()
        }
    }
}
