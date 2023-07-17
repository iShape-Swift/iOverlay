//
//  Array+Degenerates.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iFixFloat

public extension Array where Element == FixVec {
    
    mutating func removeDegenerates() {
        guard count > 2 else {
            return self.removeAll()
        }
        
        guard self.hasDegenerates() else {
            return
        }
        
        self = self.filter()
    }
    
    func removedDegenerates() -> [FixVec] {
        guard count > 2 else {
            return []
        }
        
        guard self.hasDegenerates() else {
            return self
        }
        
        return self.filter()
    }
    
    
    private func hasDegenerates() -> Bool {
        var p0 = self[count - 2]
        let p1 = self[count - 1]
        
        var v0 = p1 - p0
        p0 = p1
        
        for pi in self {
            let vi = pi - p0
            let prod = vi.unsafeCrossProduct(v0)
            if prod == 0 {
                return true
            }
            v0 = vi
            p0 = pi
        }

        return false
    }
    
    private func filter() -> [FixVec] {
        var n = count
        
        var nodes = [Node](repeating: .init(next: .zero, index: .zero, prev: .zero), count: n)
        var i0 = n - 2
        var i1 = n - 1
        for i2 in 0..<n {
            nodes[i1] = Node(next: i2, index: i1, prev: i0)
            i0 = i1
            i1 = i2
        }

        var first = 0
        
        var node = nodes[first]
        var i = 0
        while i < n {
            let p0 = self[node.prev]
            let p1 = self[node.index]
            let p2 = self[node.next]

            if (p1 - p0).unsafeCrossProduct(p2 - p1) == 0 {
                n -= 1
                if n < 3 {
                    return []
                }
                nodes.remove(node: node)
                if node.index == first {
                    first = node.next
                }
                i -= 1
            } else {
                i += 1
            }
            node = nodes[node.next]
        }
        
        guard n > 2 else {
            return []
        }
        
        i = 0
        var buffer = [FixVec](repeating: .zero, count: n)
        node = nodes[first]
        while i < n {
            buffer[i] = self[node.index]
            node = nodes[node.next]
            i += 1
        }

#if DEBUG
        var a0 = buffer[buffer.count - 1]
        for p0 in buffer {
            assert(a0 != p0)
            a0 = p0
        }
#endif
        return buffer
    }
    
}

private struct Node {
    
    let next: Int
    let index: Int
    let prev: Int

    init(next: Int, index: Int, prev: Int) {
        self.next = next
        self.index = index
        self.prev = prev
    }
}

private extension Array where Element == Node {
    
    mutating func remove(node: Node) {
        let prev = self[node.prev]
        let next = self[node.next]
        self[node.prev] = Node(next: node.next, index: prev.index, prev: prev.prev)
        self[node.next] = Node(next: next.next, index: next.index, prev: node.prev)
    }

}
