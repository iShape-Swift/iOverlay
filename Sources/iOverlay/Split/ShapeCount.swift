//
//  ShapeCount.swift
//  
//
//  Created by Nail Sharipov on 05.08.2023.
//

public struct ShapeCount {

    var isEven: Bool { subj % 2 == 0 && clip % 2 == 0 }
    
    public private (set) var subj: Int32
    public private (set) var clip: Int32

    init(subj: Int32, clip: Int32) {
        self.subj = subj
        self.clip = clip
    }

    func add(_ count: ShapeCount) -> ShapeCount {
        ShapeCount(subj: subj + count.subj, clip: clip + count.clip)
    }

    func increment(shape: ShapeType) -> ShapeCount {
        let subjCnt = ShapeType.subject & shape != 0 ? 1 + subj : subj
        let clipCnt = ShapeType.clip & shape != 0 ? 1 + clip : clip
        return ShapeCount(subj: subjCnt, clip: clipCnt)
    }
}
