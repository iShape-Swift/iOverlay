//
//  ScanSplitStore.swift
//
//
//  Created by Nail Sharipov on 06.03.2024.
//

import iFixFloat

struct CrossSegment {
    let other: XSegment
    let cross: CrossResult
}

protocol ScanSplitStore {
    
    mutating func intersectAndRemoveOther(this: XSegment) -> CrossSegment?
 
    mutating func insert(segment: XSegment)
 
    mutating func clear()
}
