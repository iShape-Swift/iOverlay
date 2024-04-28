//
//  ScanSplitStore.swift
//
//
//  Created by Nail Sharipov on 06.03.2024.
//

import iFixFloat

struct CrossSegment {
    let other: IndexSegment
    let cross: CrossResult
}

protocol ScanSplitStore {
    
    mutating func intersectAndRemoveOther(this: XSegment) -> CrossSegment?
 
    mutating func insert(segment: IndexSegment)
 
    mutating func clear()
}
