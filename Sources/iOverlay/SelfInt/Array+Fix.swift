//
//  Array+Fix.swift
//  
//
//  Created by Nail Sharipov on 11.07.2023.
//

import iFixFloat
import iShape

public extension Array where Element == FixVec {

    func split() -> [MPoint] {
        let points = self.removedDegenerates()
        guard points.count > 2 else {
            return []
        }
        
        let capacity = 3 * (points.count / 2)
        var vStore = VStore(capacity: capacity)
        let iPoints = points.indices(vStore: &vStore, mask: .empty)
        var segments = iPoints.segments
        segments.sortAndUnique()
        segments.split(vStore: &vStore)
        
        return vStore.mPnts
    }
}

extension Array where Element == FixVec {

    func indices(vStore: inout VStore, mask: Int) -> [IndexPoint] {
        let n = count
        var iPoints = [IndexPoint](repeating: .zero, count: n)

        for i in 0..<n {
            let p = self[i]
            let index = vStore.put(point: p, mask: mask)
            iPoints[i] = IndexPoint(index: index, point: p)
        }
        
        return iPoints
    }

}

extension Array where Element == IndexPoint {
    
    var segments: [Segment] {
        let n = count
        var segments = [Segment](repeating: .zero, count: n)
        
        let i0 = n - 1
        var a = self[i0]
        
        for i in 0..<n {
            let b = self[i]
            
            if a.point.bitPack < b.point.bitPack {
                segments[i] = Segment(a: a, b: b)
            } else {
                segments[i] = Segment(a: b, b: a)
            }
            
            a = b
        }
        
        return segments
    }

}

extension Array where Element == Segment {
    
    mutating func sortAndUnique() {
        self.sort(by: {
            let a0 = $0.a.point.bitPack
            let a1 = $1.a.point.bitPack
            if a0 != a1 {
                return a0 < a1
            } else {
                let b0 = $0.b.point.bitPack
                let b1 = $1.b.point.bitPack
                
                return b0 < b1
            }
        })
        
        // usually (if the path do not have loops) we will not have the same edges, so this code will work very fast
        var e0 = self[0]
        var i = 1
        while i < count {
            let ei = self[i]
            if e0 == ei {
                self.remove(at: i)
            } else {
                i += 1
                e0 = ei
            }
        }
        
#if DEBUG
        assert(Set(self).count == count)
#endif
    }

}
