//
//  ScanFillStore.swift
//
//
//  Created by Nail Sharipov on 05.03.2024.
//

import iFixFloat

protocol ScanFillStore {
 
    mutating func insert(segment: CountSegment, stop: Int32)

    mutating func findUnder(point p: Point, stop: Int32) -> ShapeCount

}
