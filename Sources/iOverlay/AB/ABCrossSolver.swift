//
//  ABCrossSolver.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iFixFloat
import iShape

private typealias ShapeId = Int

private extension ShapeId {
    static let a = 0
    static let b = 1
}

public enum ABLayout {
    case overlap
    case aInB
    case bInA
    case apart
    case aEqB
}

public struct ABCross {
    
    public let layout: ABLayout
    public let navigator: ABPinNavigator
    
    init(layout: ABLayout, navigator: ABPinNavigator) {
        self.layout = layout
        self.navigator = navigator
    }
}

public struct ABCrossSolver {
    
    public init() { }
    
    public func safeCross(pathA: [FixVec], pathB: [FixVec]) -> ABCross {
        let cleanA = pathA.fix().maxAreaPath
        let cleanB = pathB.fix().maxAreaPath
        
        let bndA = FixBnd(points: cleanA)
        let bndB = FixBnd(points: cleanB)
        
        return self.cross(pathA: cleanA, pathB: cleanB, bndA: bndA, bndB: bndB)
    }
    
    public func cross(pathA: [FixVec], pathB: [FixVec], bndA: FixBnd, bndB: FixBnd) -> ABCross {
        // at this time pathA and pathB must be correct!

        if bndA == bndB && pathA.count == pathB.count {
            // looks like a == b
            if pathA.isEqualTo(pathB) {
                return ABCross(layout: .aEqB, navigator: .empty)
            }
        }
        
        guard bndA.isCollide(bndB) else {
            return ABCross(layout: .apart, navigator: .empty)
        }

        let aEdges = pathA.filterEdges(shapeId: ShapeId.a, bnd: bndB)

        guard !aEdges.isEmpty else {
            return ABCross(layout: .apart, navigator: .empty)
        }
        
        let bEdges = pathB.filterEdges(shapeId: ShapeId.b, bnd: bndA)

        guard !bEdges.isEmpty else {
            return ABCross(layout: .apart, navigator: .empty)
        }
        
        let pins = (aEdges + bEdges).abCross()

        guard pins.count < 2 else {
            return ABCross(layout: .overlap, navigator: ABPinNavigator(pathA: pathA, pathB: pathB, pins: pins))
        }
        
        let eNavigator = ABPinNavigator(pins: pins)
        
        let anyA: FixVec
        let anyB: FixVec
        if pins.isEmpty {
            anyA = pathA[0]
            anyB = pathB[0]
        } else {
            let exPin = pins[0].p
            anyA = pathA.anyPoint(exclude: exPin)
            anyB = pathB.anyPoint(exclude: exPin)
        }
        
        if pathB.contains(point: anyA) {
            return ABCross(layout: .aInB, navigator: eNavigator)
        }

        if pathA.contains(point: anyB) {
            return ABCross(layout: .bInA, navigator: eNavigator)
        }

        return ABCross(layout: .apart, navigator: eNavigator)
    }
    
}

private extension Array where Element == FixVec {
    
    func filterEdges(shapeId: Int, bnd: FixBnd) -> [IdEdge] {
        let last = self.count - 1
        var p0 = IndexPoint(index: last, point: self[last])
        
        var edges = [IdEdge]()

        for i in 0..<self.count {
            let p1 = IndexPoint(index: i, point: self[i])
            
            let eBnd = FixBnd(p0: p0.point, p1: p1.point)
            
            if eBnd.isCollide(bnd) {
                let e = IdEdge(id: shapeId, a: p0, b: p1)
                edges.append(e)
            }
            p0 = p1
        }
        
        return edges
    }
    
    func anyPoint(exclude: FixVec) -> FixVec {
        let a = self[0]
        if a != exclude {
            return a
        } else {
            return self[1]
        }
    }
}

private extension Pin {
    
    init(e0: IdEdge, e1: IdEdge, p: FixVec) {
        i = 0
        self.p = p
        if e0.id == ShapeId.a {
            mA = e0.miliStone(p)
            mB = e1.miliStone(p)
        } else {
            mB = e0.miliStone(p)
            mA = e1.miliStone(p)
        }
    }
    
}

private extension Array where Element == Pin {
    
    mutating func appendUniq(e0: IdEdge, e1: IdEdge, p: FixVec) {
        for pin in self {
            if pin.p == p {
                return
            }
        }
        
        self.append(Pin(e0: e0, e1: e1, p: p))
    }
    
}

private extension Array where Element == IdEdge {
    
    func abCross() -> [Pin] {
        var queue = self.sorted(by: { $0.e0.bitPack > $1.e0.bitPack })
        
        var listA = [IdEdge]()
        listA.reserveCapacity(8)
        
        var listB = [IdEdge]()
        listB.reserveCapacity(8)
        
        var pins = [Pin]()

    queueLoop:
        while !queue.isEmpty {
            
            // get edge with the smallest e0
            let thisEdge = queue.removeLast()
            
            let scanList: [IdEdge]
            if thisEdge.id == ShapeId.a {
                listB.removeAllE1(before: thisEdge.e0.bitPack)
                scanList = listB
            } else {
                listA.removeAllE1(before: thisEdge.e0.bitPack)
                scanList = listA
            }
            
            // try to cross with the scan list
            for scanIndex in 0..<scanList.count {
                
                let scanEdge = scanList[scanIndex]
                
                let cross = thisEdge.cross(scanEdge)
                
                switch cross.type {
                case .not_cross:
                    break
                case .common_end:
                    pins.appendUniq(e0: thisEdge, e1: scanEdge, p: cross.point)
                case .pure:
                    let x = cross.point
                    
                    // devide edges

                    let thisLt = IdEdge(parent: thisEdge, e0: thisEdge.e0, e1: x)
                    let thisRt = IdEdge(parent: thisEdge, e0: x, e1: thisEdge.e1)
                    
                    let scanLt = IdEdge(parent: scanEdge, e0: scanEdge.e0, e1: x)
                    let scanRt = IdEdge(parent: scanEdge, e0: x, e1: scanEdge.e1)

                    queue.addE0(edge: thisLt)
                    queue.addE0(edge: thisRt)
                    queue.addE0(edge: scanRt)

                    if scanLt.id == ShapeId.a {
                        listA[scanIndex] = scanLt
                    } else {
                        listB[scanIndex] = scanLt
                    }
                    
                    continue queueLoop
                case .end_b:
                    let x = cross.point

                    // devide this edge
                    
                    let thisLt = IdEdge(parent: thisEdge, e0: thisEdge.e0, e1: x)
                    let thisRt = IdEdge(parent: thisEdge, e0: x, e1: thisEdge.e1)

                    queue.addE0(edge: thisLt)
                    queue.addE0(edge: thisRt)

                    continue queueLoop
                case .end_a:
                    let x = cross.point

                    // devide scan edge
                    
                    let scanLt = IdEdge(parent: scanEdge, e0: scanEdge.e0, e1: x)
                    let scanRt = IdEdge(parent: scanEdge, e0: x, e1: scanEdge.e1)

                    queue.addE0(edge: thisEdge) // put it back!
                    queue.addE0(edge: scanRt)
                    
                    if scanLt.id == ShapeId.a {
                        listA[scanIndex] = scanLt
                    } else {
                        listB[scanIndex] = scanLt
                    }
                    
                    continue queueLoop
                }
                
            } // for scanList
            
            // no intersections, add to scan
            if thisEdge.id == ShapeId.a {
                listA.addE0(edge: thisEdge)
            } else {
                listB.addE0(edge: thisEdge)
            }
        } // while queue
        
        if !pins.isEmpty {
            pins.sort(by: { $0.mA < $1.mA })
            for i in 0..<pins.count {
                pins[i] = Pin(i: i, pin: pins[i])
            }
        }

        return pins
    }
    
}
