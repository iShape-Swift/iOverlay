//
//  ABPinNavigator.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iFixFloat
import iShape

public struct ABPinNavigator {

    static let empty = ABPinNavigator(pins: [])
    
    struct Node {
        let next: Int
        let prev: Int
    }
    
    private struct BNode {
        let i: Int
        let m: MileStone
    }
    
    public let pins: [Pin]      // sorted by a path
    private let queue: [Node]   // index is the self order, value is next pin in b path
    
    init(pins: [Pin]) {
        assert(pins.count <= 1)
        self.pins = pins
        self.queue = []
    }
    
    init(pathA: [FixVec], pathB: [FixVec], pins: [Pin]) {
        // at this time pins is already sorted by a

        let n = pins.count
        
        assert(n >= 2)
        
        var bNodes = [BNode](repeating: BNode(i: 0, m: .zero), count: n)
        
        var i = 0
        while i < n {
            let p = pins[i]
            bNodes[i] = BNode(i: p.i, m: p.mB)
            i += 1
        }
        
        bNodes.sort(by: { $0.m < $1.m })

        var nodes = [Node](repeating: Node(next: 0, prev: 0), count: n)

        var i1 = n - 1
        var i2 = 0
        
        var j0 = bNodes[n - 2].i
        var j1 = bNodes[i1].i

        while i2 < n {
            let j2 = bNodes[i2].i
            nodes[i1] = Node(next: j2, prev: j0)
            
            j0 = j1
            j1 = j2
            
            i1 = i2
            i2 += 1
        }

        queue = nodes
//
//        var areas = [FixFloat](repeating: 0, count: pins.count)
//
//        for i in 0..<pins.count {
//            let pin0 = pins[i]
//            let pin1 = pins.next(pin: pin0)
//
//            let aArea = pathA.directArea(s0: pin0.a, s1: pin1.a)
//            let bArea = pathB.directArea(s0: pin1.b, s1: pin0.b)
//
//            let area = aArea - bArea
//            areas[i] = area
//        }
//
//        var rPins = pins
//
//        var a0 = areas[areas.count - 1]
//        for i in 0..<areas.count {
//            let a1 = areas[i]
//
//            if a1 > 0 && a0 > 0 {
//                rPins[i].type = .into_out
//            } else if a1 < 0 && a0 < 0 {
//                rPins[i].type = .out_into
//            } else if a0 != 0 && a1 != 0 {
//                if a1 > 0 {
//                    rPins[i].type = .out
//                } else {
//                    rPins[i].type = .into
//                }
//            } else if a1 == 0 {
//                if a0 > 0 {
//                    rPins[i].type = .into_empty
//                } else {
//                    rPins[i].type = .out_empty
//                }
//            } else if a0 == 0 {
//                if a1 > 0 {
//                    rPins[i].type = .empty_out
//                } else {
//                    rPins[i].type = .empty_into
//                }
//            }
//
//#if DEBUG
//            rPins[i].a0 = a0 / 1024
//            rPins[i].a1 = a1 / 1024
//#endif
//
//            a0 = a1
//        }
        
        self.pins = pins
    }
}
