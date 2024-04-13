//
//  ScanBindStore.swift
//
//
//  Created by Nail Sharipov on 26.03.2024.
//

import iFixFloat

protocol ScanBindStore {
 
    mutating func insert(segment: IdSegment, stop: Int32)

    mutating func underAndNearest(point p: Point, stop: Int32) -> Int

}
