//
//  ScanSplitStore.swift
//
//
//  Created by Nail Sharipov on 06.03.2024.
//

import iFixFloat

struct CrossSegment {
    let index: VersionedIndex
    let cross: EdgeCross
}

protocol ScanSplitStore {
    
    mutating func intersect(this: XSegment, scanPos: Point) -> CrossSegment?
 
    mutating func insert(segment: VersionSegment)
 
    mutating func clear()
}
