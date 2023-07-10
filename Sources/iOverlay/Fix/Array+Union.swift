//
//  Array+Union.swift
//  
//
//  Created by Nail Sharipov on 10.07.2023.
//

import iFixFloat
import iShape

extension Array where Element == FixEdge {
    
    func union(graph: FixerGraph) -> [[FixVec]] {
        var result = [[FixVec]]()
        var path = [FixVec]()

        var starMap = [Int: Int]()
        
        // find first edge
        var n0 = graph.first
        var ns = graph.neighbors(node: n0)
        var ni = ns[0]
        for i in 1..<ns.count {
            let n2 = ns[i]
            if Triangle.isClockwise(p0: n0.point, p1: n2.point, p2: ni.point) {
                ni = n2
            }
        }

        path.append(n0.point)
        
        if n0.isStar {
            starMap[n0.index] = 0
        }

        let start = n0.index
        
        while ni.index != start {
            path.append(ni.point)
            if ni.isStar {
                if let vi = starMap[ni.index] {
                    // we found a closed path
                    let subCount = path.count - vi
                    var subPath = [FixVec](repeating: .zero, count: subCount)
                    for i in 0..<subCount {
                        subPath[i] = path[vi + i]
                    }
                    
                    result.append(subPath)

                    path.removeLast(path.count - vi)
                } else {
                    starMap[ni.index] = path.count
                }
                
                ns = graph.nextStar(node: ni, exclude: n0)
                var n1 = ns[0]
                for i in 1..<ns.count {
                    let n2 = ns[i]
                    if Array.isFirstClockwise(center: ni.point, start: n0.point, p0: n2.point, p1: n1.point) {
                        n1 = n2
                    }
                }
                n0 = ni
                ni = n1
            } else {
                let ne = graph.next(node: ni, exclude: n0)
                n0 = ni
                ni = ne
            }
        }
        
        if path.count > 2 {
            result.append(path)
        }
        
        
        return result
    }

    private static func isFirstClockwise(center: FixVec, start: FixVec, p0: FixVec, p1: FixVec) -> Bool {
        let v0 = center - start
        let v1 = center - p0
        let v2 = center - p1
        
        let c1 = v0.unsafeCrossProduct(v1)
        let c2 = v0.unsafeCrossProduct(v2)
        
        if c1 == 0 || c2 == 0 {

            let c1Dot = v0.unsafeDotProduct(v1)
            let c2Dot = v0.unsafeDotProduct(v2)
            
            if c1 == 0 && c2 == 0 {
                if c1Dot > 0 && c2Dot > 0 || c1Dot < 0 && c2Dot < 0 {
                    let d1 = v1.sqrLength
                    let d2 = v2.sqrLength
                    if c1Dot > 0 {
                        return d1 < d2
                    } else {
                        return d1 > d2
                    }
                } else {
                    return c1Dot < 0
                }
            } else if c1 == 0 {
                if c1Dot > 0 {
                    return false
                } else {
                    return c2 > 0
                }
            } else {
                if c2Dot > 0 {
                    return true
                } else {
                    return c1 < 0
                }
            }
        } else {
            if c1 > 0 {
                if c2 > 0 {
                    return v1.unsafeCrossProduct(v2) < 0
                } else {
                    return false
                }
            } else {
                if c2 > 0 {
                    return true
                } else {
                    return v1.unsafeCrossProduct(v2) < 0
                }
            }
        }
    }
}
