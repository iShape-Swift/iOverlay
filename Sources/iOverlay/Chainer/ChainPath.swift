//
//  ChainPath.swift
//  
//
//  Created by Nail Sharipov on 21.07.2023.
//

import iFixFloat
import iShape

struct ChainPath {
   
    var next: Int   // top
    var prev: Int   // bottom
    var nextPoint: FixVec
    var prevPoint: FixVec
    
    init(next: Int, nextPoint: FixVec, prev: Int, prevPoint: FixVec, list: inout LinkedList) {
        self.next = next
        self.nextPoint = nextPoint
        self.prev = prev
        self.prevPoint = prevPoint

        list.join(next: next, prev: prev)
    }
    
    mutating func close(_ index: Int, nextPoint: FixVec, prevPoint: FixVec, list: inout LinkedList) {
        list.join(next: next, index: index, prev: prev)
        
        self.nextPoint = nextPoint
        self.prevPoint = prevPoint
        
        next = index
        prev = index
    }
    
    mutating func joinToPrev(_ index: Int, other: ChainPath, list: inout LinkedList) {
        list.join(next: other.next, index: index, prev: prev)
        prev = other.prev
        prevPoint = other.prevPoint
    }
    
    mutating func joinToNext(_ index: Int, other: ChainPath, list: inout LinkedList) {
        list.join(next: next, index: index, prev: other.prev)
        next = other.next
        nextPoint = other.nextPoint
    }
    
    mutating func joinToNext(_ index: Int, point: FixVec, list: inout LinkedList) {
        list.join(next: next, index: index)
        next = index
        nextPoint = point
    }

    mutating func joinToPrev(_ index: Int, point: FixVec, list: inout LinkedList) {
        list.join(prev: prev, index: index)
        prev = index
        prevPoint = point
    }
    
    mutating func joinToPrev(other: ChainPath, list: inout LinkedList) {
        list.join(next: prev, prev: other.next)
        prev = other.prev
        prevPoint = other.prevPoint
    }
    
    mutating func joinToNext(other: ChainPath, list: inout LinkedList) {
        list.addToNext(next, index: other.prev)
        next = other.next
        nextPoint = other.nextPoint
    }
    
    mutating func closeNextToPrev(other: ChainPath, list: inout LinkedList) {
        list.join(next: next, prev: other.prev)
    }

    mutating func close(list: inout LinkedList) {
        list.addToNext(next, index: prev)
    }
    
    func path(list: LinkedList, edges: [SelfEdge]) -> FixPath {
        var index = next
        var path = FixPath()
        
        var p = nextPoint
        path.append(p)

        repeat {
            let e = edges[index]
            p = p == e.a ? e.b : e.a
            index = list[index].next
            path.append(p)
        } while index != next
        
        return path
    }
    
    
    func invertedFromNextToPrev(list: inout LinkedList) -> ChainPath {
        list.invert(oldNext: next, oldPrev: prev)
        
        return ChainPath(
            next: prev,
            nextPoint: prevPoint,
            prev: next,
            prevPoint: nextPoint,
            list: &list
        )
    }
    
    func invertedFromPrevToNext(list: inout LinkedList) -> ChainPath {
        list.invert(oldPrev: prev, oldNext: next)
        
        return ChainPath(
            next: prev,
            nextPoint: prevPoint,
            prev: next,
            prevPoint: nextPoint,
            list: &list
        )
    }
    
}
