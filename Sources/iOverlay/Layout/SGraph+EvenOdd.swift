//
//  SGraph+EvenOdd.swift
//  
//
//  Created by Nail Sharipov on 26.07.2023.
//

import iFixFloat
import iShape

public extension SGraph {
    
    func shapes() -> [FixPath] {
        let n = links.count
        var visited = [Bool](repeating: false, count: n)

        var result = [FixPath]()
        
        for i in 0..<n {
            if !visited[i] {
                // new contour
                
            }
        }
        
        return result
    }

    
    private func contour(index: Int, visited: inout [Bool]) -> FixPath {
        var path = FixPath()
        var next = index

        var link = links[index]

        var a = link.a
        var b = link.b
        
        path.append(a.point)
        
        repeat {
            path.append(link.b.point)
            let node = nodes[link.b.index]
            
            if node.count == 2 {
                next = node.other(index: next)
                link = links[next]
                a = b
                b = link.other(b)
            } else {
                let isCW = SGraph.isClockWise(a: link.a.point, b: link.b.point, isTopInside: link.fill == .subjectTop)
                
            }
            

        } while next != index

        return path
    }

    
    private static func isClockWise(a: FixVec, b: FixVec, isTopInside: Bool) -> Bool {
        let isDirect = a.bitPack < b.bitPack

        return xnor(isDirect, isTopInside)
    }
    
    private static func xnor(_ a: Bool, _ b: Bool) -> Bool {
        a && b || !(a || b)
    }
    
    private func first(_ start: IndexPoint, link: SLink, isClockWise: Bool, visited: [Bool]) -> SLink {
        let center = link.other(start)
        let node = nodes[center.index]
        
        let v = start.point - center.point
        
        var result = SLink(a: .zero, b: .zero, fill: 0)
        
        var isFound = false
        
        // first try to found smaller 180
        
        var i = node.data0
        let last = i + node.count
        
        
        while i < last {
            if !visited[i] {
                
            }
            
            i += 1
        }
        
        return result
    }

}
