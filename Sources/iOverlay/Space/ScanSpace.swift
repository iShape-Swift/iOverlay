//
//  ScanSpace.swift
//
//
//  Created by Nail Sharipov on 11.01.2024.
//

public struct ScanSegment<Id, Unit> {
    let id: Id
    public let range: LineRange
    public let stop: Unit
}

public struct ScanItem<Id> {
    public let id: Id
    public let index: DualIndex
}

public struct ScanSpace<Id, Unit: Comparable> {
    
    public let indexer: LineIndexer
    private var heaps: [[ScanSegment<Id, Unit>]]
    private var indexBuffer: [Int] = []
    
    public init(range: LineRange, count: Int) {
        let maxLevel = max(2, Int(Double(count).squareRoot()).logTwo)
        indexer = LineIndexer(level: maxLevel, range: range)
        heaps = [[ScanSegment]](repeating: [], count: indexer.size)
    }
    
    public mutating func insert(segment: ScanSegment<Id, Unit>) {
        let index = indexer.unsafe_index(range: segment.range)
        heaps[index].append(segment)
    }
    
    public mutating func clear() {
        for i in 0..<heaps.count {
            heaps[i].removeAll(keepingCapacity: true)
        }
    }
    
    public mutating func idsInRange(range: LineRange, stop: Unit, ids: inout [Id]) {
        indexer.fillUnsafe(range: range, buffer: &indexBuffer)
        
        heaps.withUnsafeMutableBufferPointer { heapsBuffer in
            for major in indexBuffer {
                assert(major < heapsBuffer.count)
                if let segments = heapsBuffer.baseAddress?.advanced(by: major) {
                    var minor = 0
                    while minor < segments.pointee.count {
                        let seg = segments.pointee[minor]
                        if seg.stop <= stop {
                            if minor + 1 < segments.pointee.count {
                                segments.pointee.swapRemove(minor)
                            } else {
                                _ = segments.pointee.removeLast()
                            }
                        } else {
                            if seg.range.isOverlap(range) {
                                ids.append(seg.id)
                            }
                            minor += 1
                        }
                    }
                }
            }
            // Unsafe block ends here
        }
        
        indexBuffer.removeAll(keepingCapacity: true)
    }
    
    public mutating func itemsInRange(range: LineRange, stop: Unit, items: inout [ScanItem<Id>]) {
        indexer.fillUnsafe(range: range, buffer: &indexBuffer)

        heaps.withUnsafeMutableBufferPointer { heapsBuffer in
            for major in indexBuffer {
                if let segments = heapsBuffer.baseAddress?.advanced(by: major) {
                    var minor = 0
                    while minor < segments.pointee.count {
                        let seg = segments.pointee[minor]
                        if seg.stop <= stop {
                            if minor + 1 < segments.pointee.count {
                                segments.pointee.swapRemove(minor)
                            } else {
                                _ = segments.pointee.removeLast()
                            }
                        } else {
                            if seg.range.isOverlap(range) {
                                items.append(ScanItem(id: seg.id, index: DualIndex(major: UInt32(major), minor: UInt32(minor))))
                            }
                            minor += 1
                        }
                    }
                }
            }
        }
        
        indexBuffer.removeAll(keepingCapacity: true)
    }
    
    public mutating func remove(indices: inout [DualIndex]) {
        let n = indices.count
        guard n > 0 else {
            return
        }
        
        defer {
            indices.removeAll(keepingCapacity: true)
        }
        
        if n == 1 {
            self.remove(index: indices[0])
        } else {
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
        
        indices.removeAll(keepingCapacity: true)
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
}

private extension Array {
    mutating func swapRemove(_ index: Int) {
        if index < self.count - 1 {
            self[index] = self.removeLast()
        } else {
            self.removeLast()
        }
    }
}
