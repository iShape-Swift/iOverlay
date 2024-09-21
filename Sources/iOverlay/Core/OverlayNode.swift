//
//  OverlayNode.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

struct OverlayNode {
        
    var indices: [Int]

    @inline(__always)
    func other(index: Int) -> Int {
        assert(indices.count == 2)
        return indices[0] == index ? indices[1] : indices[0]
    }
    
    @inline(__always)
    func firstNotVisited(visited: [Bool]) -> (Int, Int) {
        var itIndex = 0
        while itIndex < self.indices.count {
            let linkIndex = self.indices[itIndex]
            itIndex += 1
            if !visited[linkIndex] {
                return (itIndex, linkIndex)
            }
        }
        fatalError("The loop should always return")
    }
    
    @inline(__always)
    func nextLink(itIndex: inout Int, visited: [Bool]) -> Int {
        while itIndex < self.indices.count {
            let linkIndex = self.indices[itIndex]
            itIndex += 1
            if !visited[linkIndex] {
                return linkIndex
            }
        }

        return Int.max
    }
}
