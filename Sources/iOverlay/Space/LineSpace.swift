//
//  LineSpace.swift
//
//
//  Created by Nail Sharipov on 06.12.2023.
//

public struct LineSpace<Id> {

    
    public let indexer: LineIndexer
    private var buffer: [Int] = []
    private (set) var heaps: [[LineSegment<Id>]]
    
    public init(level: Int, range: LineRange) {
        indexer = LineIndexer(level: level, range: range)
        heaps = [[LineSegment]](repeating: [], count: indexer.size)
    }
    
    public mutating func insert(segment: LineSegment<Id>) {
        let index = indexer.index(range: segment.range)
        heaps[index].append(segment)
    }
    
    public mutating func remove(index: DualIndex) {
        let heapIndex = Int(index.major)
        let listIndex = Int(index.minor)

        if listIndex + 1 < heaps[heapIndex].count {
            heaps[heapIndex][listIndex] = heaps[heapIndex].removeLast()
        } else {
            heaps[heapIndex].removeLast()
        }
    }
    
    public mutating func clear() {
        for i in 0..<heaps.count {
            heaps[i].removeAll(keepingCapacity: true)
        }
    }
    
    public mutating func fillIdsInRange(range: LineRange, ids: inout [Id]) {
        indexer.fill(range: range, buffer: &buffer)
            
        for heapIndex in buffer {
            let segments = heaps[heapIndex]
            for segm in segments where segm.range.isOverlap(range) {
                ids.append(segm.id)
            }
        }
        
        buffer.removeAll(keepingCapacity: true)
    }
    
    public mutating func allInRange(range: LineRange, containers: inout [LineContainer<Id>]) {
        indexer.fill(range: range, buffer: &buffer)

        containers.removeAll(keepingCapacity: true)
        for heapIndex in buffer {
            let segments = heaps[heapIndex]

            for segmentIndex in 0..<segments.count {
                if range.isOverlap(segments[segmentIndex].range) {
                    containers.append(.init(id: segments[segmentIndex].id, index: .init(major: UInt32(heapIndex), minor: UInt32(segmentIndex))))
                }
            }
        }
        
        buffer.removeAll(keepingCapacity: true)
    }
    
    public mutating func remove(indices: inout [DualIndex]) {
        guard indices.count > 1 else {
            self.remove(index: indices[0])
            return
        }
        
        indices.sort(by: {
            if $0.major == $1.major {
                return $0.minor > $1.minor
            } else {
                return $0.major < $1.major
            }
        })

        for index in indices {
            self.remove(index: index)
        }
    }
    
}
