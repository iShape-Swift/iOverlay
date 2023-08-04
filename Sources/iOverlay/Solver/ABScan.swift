//
//  ABScan.swift
//  
//
//  Created by Nail Sharipov on 31.07.2023.
//

import iFixFloat
import iShape

struct ABScanResult {
    
    let hasNext: Bool
    let index: Int
    let edge: SelfEdge
    
}

struct ABScan {
    
    private var edges: [SelfEdge]
    private var itIndex: Int
    private var itStart: Int64
    private var itEnd: Int64
    
    var isEmpty: Bool { edges.isEmpty }
    
    init(edges: [SelfEdge], bnd: FixBnd) {
        self.edges = edges.filter(bnd)
        itIndex = 0
        itStart = 0
        itEnd = 0
    }
    
    mutating func startIterate(start: Int64, end: Int64) {
        itIndex = -1
        itStart = start
        itEnd = end
    }
    
    @inlinable
    mutating func next() -> ABScanResult {
        itIndex += 1
        
        while itIndex < edges.count {
            let edge = edges[itIndex]
            guard edge.a.bitPack < itEnd else {
                return ABScanResult(hasNext: false, index: itIndex, edge: .zero)
            }
            
            if edge.b.bitPack <= itStart {
                self.edges.remove(at: itIndex)
                continue
            }
            
            return ABScanResult(hasNext: true, index: itIndex, edge: edge)
        }
        
        return ABScanResult(hasNext: false, index: itIndex, edge: .zero)
    }
    
    @inlinable
    mutating func insert(newEdge: SelfEdge) {
        let index = edges.aFindNewEdgeIndex(newEdge.edge)
        var i = index - 1
        while i >= 0 {
            let edge = edges[i]
            if edge.isEqual(newEdge) {
                // do not insert if already exist
                return
            } else if edge.isLessA(newEdge) {
                break
            }
            
            i -= 1
        }
        
        edges.insert(newEdge, at: index)
    }
    
    @inlinable
    mutating func remove(at: Int) {
        edges.remove(at: at)
    }
}


private extension Array where Element == SelfEdge {
    
    func filter(_ bnd: FixBnd) -> [SelfEdge] {
        var result = [SelfEdge]()
        
        for edge in self {
            if bnd.isCollide(FixBnd(edge: edge)) {
                result.append(edge)
            }
        }
        
        return result
    }
    
}
