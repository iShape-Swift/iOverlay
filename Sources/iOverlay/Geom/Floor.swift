//
//  Floor.swift
//
//
//  Created by Nail Sharipov on 25.01.2024.
//

import iFixFloat
import iShape

struct Floor {
    let id: Int
    let seg: XSegment
    
    init(id: Int, a: FixVec, b: FixVec) {
        self.id = id
        self.seg = XSegment(a: a, b: b)
    }
}

extension FixPath {
    
    func floors(id: Int, xMin: Int32, xMax: Int32) -> [Floor] {
        var list = [Floor]()
        let n = self.count
        list.reserveCapacity(3 * n / 4)
        
        var b = self[n - 1]
        for a in self {
            if a.x < b.x && xMin < b.x && a.x <= xMax {
                list.append(Floor(id: id, a: a, b: b))
            }
            b = a
        }
        return list
    }
}

extension VectorPath {
    
    func floors(id: Int, xMin: Int32, xMax: Int32) -> [Floor] {
        var list = [Floor]()
        let n = self.count
        list.reserveCapacity(3 * n / 4)
        
        for vec in self {
            if vec.a.x < vec.b.x && xMin < vec.b.x && vec.a.x <= xMax {
                list.append(Floor(id: id, a: vec.a, b: vec.b))
            }
        }
        return list
    }
}
