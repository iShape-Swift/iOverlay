//
//  ShapeCount.swift
//  
//
//  Created by Nail Sharipov on 05.08.2023.
//

public struct ShapeCount {

    public let subj: Int32
    public let clip: Int32
    
    @inline(__always)
    var isEmpty: Bool {
        subj == 0 && clip == 0
    }
    
    @inline(__always)
    public init(subj: Int32, clip: Int32) {
        self.subj = subj
        self.clip = clip
    }
    
    @inline(__always)
    func add(_ count: ShapeCount) -> ShapeCount {
        ShapeCount(subj: subj + count.subj, clip: clip + count.clip)
    }
    
    @inline(__always)
    func invert() -> ShapeCount {
        ShapeCount(subj: -subj, clip: -clip)
    }
}
