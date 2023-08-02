//
//  File.swift
//  
//
//  Created by Nail Sharipov on 01.08.2023.
//

import iFixFloat
import iShape

extension BoolShape {
    
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
                        
                        if scan.a == segm.a {
                            if scan.b == segm.b {
                                isShape = true
                            } else if scan.a.x != scan.b.x {
                                let isCW = Triangle.isClockwise(p0: scan.a, p1: segm.b, p2: scan.b)
                                if isCW {
                                    cnt += 1
                                }
                            }
                        } else if scan.b.x > segm.a.x {
                            let v0 = scan.b - scan.a
                            let v1 = segm.a - scan.a
                            let cross = v0.unsafeCrossProduct(v1)
                            if cross > 0 {
                                cnt += 1
                            }
                        }

                        j += 1
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
}
