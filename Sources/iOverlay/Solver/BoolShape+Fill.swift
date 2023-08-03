//
//  BoolShape+Fill.swift
//  
//
//  Created by Nail Sharipov on 01.08.2023.
//

import iFixFloat
import iShape

extension BoolShape {

    @inlinable
    static func fill(edges: [SelfEdge], segments: inout [Segment], fillTop: FillMask, fillBottom: FillMask) {
        let en = edges.count
        let sn = segments.count
        
        var scanList = [SelfEdge]()

        var si = 0
        var ei = 0
        
        while si < sn && ei < en {
            let sx = segments[si].a.x
            
            while ei < en {
                let e = edges[ei]
                if e.a.x <= sx {
                    ei += 1
                    if e.b.x >= sx {
                        scanList.append(e)
                    }
                } else {
                    break
                }
            }
            
            while si < sn {
                var segm = segments[si]
                if segm.a.x != sx {
                    break
                }
                
                var j = 0
                var isShape = false
                var cnt = 0
                while j < scanList.count {
                    let scan = scanList[j]

                    if scan.b.x < segm.a.x {
                        scanList.remove(at: j)
                    } else {

                        j += 1
                        
                        if scan.a == segm.a {
                            
                            // have a common point
                            
                            if scan.b == segm.b {
                                // find self
                                isShape = true
                                continue
                            }
                            
                            if scan.a.x == scan.b.x {
                                // skip verticals
                                continue
                            }

                            if Triangle.isClockwise(p0: scan.a, p1: segm.b, p2: scan.b) {
                                cnt += 1
                            }
                            
                        } else if scan.b.x > segm.a.x && Triangle.isClockwise(p0: scan.a, p1: segm.a, p2: scan.b) {
                            cnt += 1
                        }
                    }
                }
                
                var fill = 0
                if isShape {
                    // segment belong shape
                    fill = cnt % 2 == 0 ? fillTop : fillBottom
                } else if cnt % 2 == 1 {
                    fill = fillTop | fillBottom
                }
                segm.fill = segm.fill | fill
                segments[si] = segm
                
                si += 1
            }
        }
    }

    @inlinable
    static func fill(segments: inout [Segment], fillTop: FillMask, fillBottom: FillMask) {
        let n = segments.count

        var i = 0
        var scanList = [Segment]()
        
        while i < n {
            let x = segments[i].a.x
            
            let i0 = i

            while i < n {
                let si = segments[i]
                if si.a.x == x {
                    scanList.append(si)
                    i += 1
                } else {
                    break
                }
            }
            
            var k = i0
            while k < i {
                var segm = segments[k]
                
                var j = 0
                var cnt = 0
                while j < scanList.count {
                    let scan = scanList[j]

                    if scan.b.x <= x {
                        scanList.remove(at: j)
                    } else {

                        if scan.a == segm.a {
                            // have a common point "a"

                            if Triangle.isClockwise(p0: scan.a, p1: segm.b, p2: scan.b) {
                                cnt += 1
                            }
                            
                        } else if scan.b.x > segm.a.x && Triangle.isClockwise(p0: scan.a, p1: segm.a, p2: scan.b) {
                            cnt += 1
                        }
                        
                        j += 1
                    }
                }
                
                segm.fill = cnt % 2 == 0 ? fillTop : fillBottom
                
                segments[k] = segm
                
                k += 1
            }
        }
    }
    
}
