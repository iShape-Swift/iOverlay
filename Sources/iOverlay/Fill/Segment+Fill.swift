//
//  Segment+Fill.swift
//  
//
//  Created by Nail Sharipov on 04.08.2023.
//

import iShape

extension Array where Element == Segment {
    
    mutating func fill() {
        var scanList = [Segment]()
        
        let n = self.count
        var i = 0
        
        while i < n {
            let x = self[i].a.x
            
            let i0 = i

            while i < n {
                let si = self[i]
                if si.a.x == x {
                    if si.b.x != si.a.x {
                        // do not include verticals
                        scanList.append(si)
                    }
                    i += 1
                } else {
                    break
                }
            }
            
            var k = i0
            while k < i {
                var segm = self[k]
                
                var j = 0
                var count = ShapeCount(subj: 0, clip: 0)
                while j < scanList.count {
                    let scan = scanList[j]

                    if scan.b.x <= x {
                        scanList.remove(at: j)
                    } else {

                        if scan.a == segm.a {
                            // have a common point "a"

                            if Triangle.isClockwise(p0: scan.a, p1: segm.b, p2: scan.b) {
                                count = count.increment(shape: scan.shape)
                            }
                            
                        } else if scan.b.x > segm.a.x && Triangle.isClockwise(p0: scan.a, p1: segm.a, p2: scan.b) {
                            count = count.increment(shape: scan.shape)
                        }
                        
                        j += 1
                    }
                }
                
                let subjFill: SegmentFill
                let outSubj = count.subj % 2 == 0
                if segm.shape & ShapeType.subject != 0 {
                    subjFill = outSubj ? .subjectTop : .subjectBottom
                } else {
                    subjFill = outSubj ? 0 : .subjectTop | .subjectBottom
                }

                let clipFill: SegmentFill
                let outClip = count.clip % 2 == 0
                if segm.shape & ShapeType.clip != 0 {
                    clipFill = outClip ? .clipTop : .clipBottom
                } else {
                    clipFill = outClip ? 0 : .clipTop | .clipBottom
                }

                segm.fill = subjFill | clipFill
                
                self[k] = segm
                
                k += 1
            }
        }
    }
}
