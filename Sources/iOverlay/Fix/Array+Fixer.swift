//
//  Array+Fixer.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iFixFloat
import iShape

public extension Array where Element == FixVec {
    
    func fix() -> [[FixVec]] {
        let clean = self.removedDegenerates()
        guard clean.count > 2 else {
            return [clean]
        }
        var edges = clean.createEdges()
        
        var count = 0
        
        var isModified = true
        repeat {
            let result = edges.cross()
            edges = result.edges
            isModified = result.isAnyBend
            count += 1
        } while isModified
        
        debugPrint("divide count: \(count)")
        
        guard edges.count != clean.count else { return [clean] }
        
        let graph = FixerGraph(edges: edges)
        
        return edges.union(graph: graph)
    }
    
    private func createEdges() -> [FixEdge] {
        var edges = [FixEdge](repeating: .zero, count: count)
        var a = self[count - 1]
        for i in 0..<count {
            let b = self[i]
            if a.bitPack > b.bitPack {
                edges[i] = FixEdge(e0: b, e1: a)
            } else {
                edges[i] = FixEdge(e0: a, e1: b)
            }
            a = b
        }
        return edges
    }
}

private struct CrossResult {
    let isAnyBend: Bool
    let edges: [FixEdge]
}

private extension Array where Element == FixEdge {
    
    func cross() -> CrossResult {
        var queue = self.sorted(by: { $0.e0.bitPack > $1.e0.bitPack })
        
        var scanList = [FixEdge]()
        scanList.reserveCapacity(8)
        
        var result = [FixEdge]()
        result.reserveCapacity(count)
        
        var isAnyBend = false
        
    queueLoop:
        while !queue.isEmpty {
            
            // get edge with the smallest e0
            let thisEdge = queue.removeLast()
            
            let completed = scanList.allE1(before: thisEdge.e0.bitPack)
            if completed > 0 {
                let i0 = scanList.count - completed
                let i1 = scanList.count
                result.append(contentsOf: scanList[i0..<i1])
                scanList.removeLast(completed)
            }
            
            // try to cross with the scan list
            for scanIndex in 0..<scanList.count {
                
                let scanEdge = scanList[scanIndex]
                
                let cross = thisEdge.cross(scanEdge)
                
                switch cross.type {
                case .not_cross, .common_end:
                    break
                case .pure:
                    let x = cross.point
                    
                    // devide edges
                    
                    isAnyBend = isAnyBend || Triangle.isNotLine(p0: thisEdge.e0, p1: thisEdge.e1, p2: x)
                    
                    let thisLt = FixEdge(e0: thisEdge.e0, e1: x)
                    let thisRt = FixEdge(e0: x, e1: thisEdge.e1)
                    
                    isAnyBend = isAnyBend || Triangle.isNotLine(p0: scanEdge.e0, p1: scanEdge.e1, p2: x)
                    
                    let scanLt = FixEdge(e0: scanEdge.e0, e1: x)
                    let scanRt = FixEdge(e0: x, e1: scanEdge.e1)

                    queue.addE0(edge: thisLt)
                    queue.addE0(edge: thisRt)
                    queue.addE0(edge: scanRt)

                    scanList[scanIndex] = scanLt
                    
                    continue queueLoop
                case .end_b:
                    let x = cross.point

                    // devide this edge
                    
                    isAnyBend = isAnyBend || Triangle.isNotLine(p0: thisEdge.e0, p1: thisEdge.e1, p2: x)
                    
                    let thisLt = FixEdge(e0: thisEdge.e0, e1: x)
                    let thisRt = FixEdge(e0: x, e1: thisEdge.e1)

                    queue.addE0(edge: thisLt)
                    queue.addE0(edge: thisRt)

                    continue queueLoop
                case .end_a:
                    let x = cross.point

                    // devide scan edge
                    
                    isAnyBend = isAnyBend || Triangle.isNotLine(p0: scanEdge.e0, p1: scanEdge.e1, p2: x)
                    
                    let scanLt = FixEdge(e0: scanEdge.e0, e1: x)
                    let scanRt = FixEdge(e0: x, e1: scanEdge.e1)

                    queue.addE0(edge: thisEdge) // put it back!
                    queue.addE0(edge: scanRt)
                    
                    scanList[scanIndex] = scanLt
                    
                    continue queueLoop
                }
                
            } // for scanList
            
            // no intersections, add to scan
            scanList.addE0(edge: thisEdge)
        } // while queue
        
        
        result.append(contentsOf: scanList)
        
        return CrossResult(isAnyBend: isAnyBend, edges: result)
    }
    
}
