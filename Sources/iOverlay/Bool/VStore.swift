//
//  VStore.swift
//  
//
//  Created by Nail Sharipov on 18.07.2023.
//

import iFixFloat

public struct MPoint {
    
    static let empty = MPoint(mask: 0, point: .zero)
    
    public let mask: ShapeMask
    public let point: FixVec
}

struct VStore {

    private var map: [FixVec: Int]
    private (set) var mPnts: [MPoint]
    
    @inlinable
    init(capacity: Int) {
        map = [FixVec: Int]()
        map.reserveCapacity(capacity)
        
        mPnts = [MPoint]()
        mPnts.reserveCapacity(capacity)
    }

//    @inlinable
//    init(points: [FixVec]) {
//        map = [FixVec: Int]()
//        map.reserveCapacity(points.count)
//        
//        mPnts = [MPoint]()
//        mPnts.reserveCapacity(points.count)
//        
//        self.add(points: points, mask: 0)
//    }
//    
//    @inlinable
//    mutating func add(points: [FixVec], mask: Int) {
//        for p in points {
//            self.put(point: p, mask: mask)
//        }
//    }
    
    @inlinable
    mutating func put(point: FixVec, mask: Int) -> Int {
        let index: Int
        if let i = map[point] {
            let mPnt = mPnts[i]
            if mPnt.mask != mask {
                mPnts[i] = MPoint(mask: mPnt.mask | mask, point: mPnt.point)
            }
            index = i
        } else {
            index = mPnts.count
            map[point] = index
            mPnts.append(MPoint(mask: mask, point: point))
        }
        return index
    }
    
//    @inlinable
//    mutating func put(point: FixVec, mask: Int) {
//        if let i = map[point] {
//            let mPnt = mPnts[i]
//            if mPnt.mask != mask {
//                mPnts[i] = MPoint(mask: mPnt.mask | mask, point: mPnt.point)
//            }
//        } else {
//            map[point] = mPnts.count
//            mPnts.append(MPoint(mask: mask, point: point))
//        }
//    }
//    

    @inlinable
    func point(index: Int) -> MPoint {
        mPnts[index]
    }

    @inlinable
    func index(point: FixVec) -> Int {
        map[point, default: -1]
    }
    
}
