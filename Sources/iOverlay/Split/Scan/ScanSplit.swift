//
//  ScanSplit.swift
//
//
//  Created by Nail Sharipov on 06.03.2024.
//

struct CrossSegment {
    let index: VersionedIndex
    let cross: EdgeCross
    let edge: ShapeEdge
}

protocol ScanSplit {
    
    mutating func intersect(xSegment: XSegment, scanPos: Int32, shapeSource: (VersionedIndex) -> ShapeEdge?) -> CrossSegment?
 
    mutating func insert(segment: VersionSegment)
    
    mutating func remove(segment: VersionSegment)
 
    mutating func clear()
}
