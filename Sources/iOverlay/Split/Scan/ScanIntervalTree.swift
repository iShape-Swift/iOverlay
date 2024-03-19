//
//  ScanIntervalTree.swift
//  
//
//  Created by Nail Sharipov on 06.03.2024.
//

import iFixFloat
import iTree

#if DEBUG
struct IntervalNode {
    let range: LineRange
    var list: [VersionSegment]
}
#else
private struct IntervalNode {
    let range: LineRange
    var list: [VersionSegment]
}
#endif

extension IntervalNode {
    init(range: LineRange) {
        self.range = range
        self.list = [VersionSegment]()
        self.list.reserveCapacity(4)
    }
}

struct ScanIntervalTree {

    fileprivate let power: Int
    fileprivate var nodes: [IntervalNode]

    private static func initNodes(range: LineRange, power: Int) -> [IntervalNode] {
        let n = 1 << power
        
        // to make round more precise we use upscale/downscale
        let scale = 4
        let len = range.max - range.min
        let step = Int64(Double((1 << scale) * len) / Double(n))
        
        let capacity = (n << 1) - 1
        var nodes = [IntervalNode](repeating: IntervalNode(range: LineRange(min: 0, max: 0)), count: capacity)
        
        var i = 0
        var a0 = range.min
        var s = Int64(range.min) << scale
        while i < capacity - 1 {
            s += step
            let a = Int32(s >> scale)
            nodes[i] = IntervalNode(range: LineRange(min: a0, max: a))
            i += 2
            a0 = a
        }
        nodes[i] = IntervalNode(range: LineRange(min: a0, max: range.max))
        
        for j in 2...power {
            let t = 1 << j
            let r = t >> 2
            var i = (t >> 1) - 1
            while i < capacity {
                let lt = i - r
                let rt = i + r
                let ltMin = nodes[lt].range.min
                let rtMax = nodes[rt].range.max
                nodes[i] = IntervalNode(range: LineRange(min: ltMin, max: rtMax))
                i += t
            }
        }
        
        // middle
        nodes[(1 << power) - 1] = IntervalNode(range: range)
        
        return nodes
    }
    
    init(range: LineRange, count: Int) {
        let maxPowerInterval = range.logTwo
        let maxPowerCount = Int32(Double(count).squareRoot()).logTwo
        self.power = Swift.min(maxPowerInterval, maxPowerCount)
        nodes = Self.initNodes(range: range, power: power)
    }
    
    init(range: LineRange, power: Int) {
        self.power = power
        self.nodes = Self.initNodes(range: range, power: power)
    }
    
    mutating func insert(segment: VersionSegment) {
        var s = 1 << power
        var i = s - 1
        let range = segment.xSegment.yRange
        
        while s > 1 {
            s >>= 1
            let middle = self.nodes[i].range.middle
            if range.max <= middle {
                i -= s
            } else if range.min >= middle {
                i += s
            } else {
                break
            }
        }
        // at this moment segment is in the middle of node[i]
        if s <= 1 || self.nodes[i].range == range {
            nodes[i].list.append(segment)
            return
        }
        
        let iLt = i - s
        let iRt = i + s
        
        var earlyOut = false
        
        // for min end
        var e = range.min
        let sm = s
        i = iLt

        while s > 1 {
            let middle = nodes[i].range.middle
            
            s >>= 1
            
            let lt = i - s
            let rt = i + s
            
            if e <= middle {
                assert(!nodes[rt].list.contains(where: { $0 == segment }))
                nodes[rt].list.append(segment)
                if e == middle {
                    // no more append is possible
                    earlyOut = true
                    break
                }
                i = lt
            } else {
                i = rt
            }
        }
        
        // add to leaf anyway
        if !earlyOut {
            // we down to a leaf, add it anyway
            assert(!nodes[i].list.contains(where: { $0 == segment }))
            nodes[i].list.append(segment)
        }
        
        earlyOut = false
        
        // for max end
        e = range.max
        s = sm
        i = iRt
        
        while s > 1 {
            let middle = nodes[i].range.middle
            
            s >>= 1
            let lt = i - s
            let rt = i + s

            if e >= middle {
                assert(!nodes[lt].list.contains(where: { $0 == segment }))
                nodes[lt].list.append(segment)
                if e == middle {
                    // no more append is possible
                    earlyOut = true
                    break
                }
                i = rt
            } else {
                i = lt
            }
        }
                
        if !earlyOut {
            // we down to a leaf, add it anyway
            assert(!nodes[i].list.contains(where: { $0 == segment }))
            nodes[i].list.append(segment)
        }
    }
    
    mutating func remove(segment: VersionSegment, scanPos: Int32) {
        // same logic as for insert but now we remove
        
        var s = 1 << power
        var i = s - 1
        let range = segment.xSegment.yRange
        
        while s > 1 {
            s >>= 1
            let middle = self.nodes[i].range.middle
            if range.max <= middle {
                i -= s
            } else if range.min >= middle {
                i += s
            } else {
                break
            }
        }
        
        // at this moment segment is in the middle of node[i]
        if s <= 1 || self.nodes[i].range == range {
            nodes[i].list.remove(segment: segment, scanPos: scanPos)
            return
        }
        
        let iLt = i - s
        let iRt = i + s
        
        var earlyOut = false
        
        // for min end
        var e = range.min
        let sm = s
        i = iLt

        while s > 1 {
            let middle = nodes[i].range.middle

            s >>= 1
            
            let lt = i - s
            let rt = i + s
            
            i = lt
            
            if e <= middle {
                nodes[rt].list.remove(segment: segment, scanPos: scanPos)
                if e == middle {
                    earlyOut = true
                    break
                }
                i = lt
            } else {
                i = rt
            }
        }
        
        if !earlyOut {
            nodes[i].list.remove(segment: segment, scanPos: scanPos)
        }
        
        earlyOut = false
        
        // for max end
        e = range.max
        s = sm
        i = iRt
        
        while s > 1 {
            let middle = nodes[i].range.middle
            
            s >>= 1
            let lt = i - s
            let rt = i + s

            if e >= middle {
                nodes[lt].list.remove(segment: segment, scanPos: scanPos)
                if e == middle {
                    earlyOut = true
                    break
                }
                i = rt
            } else {
                i = lt
            }
        }
                
        if !earlyOut {
            nodes[i].list.remove(segment: segment, scanPos: scanPos)
        }
    }
    
    mutating func intersect(xSegment: XSegment, scanPos: Int32, shapeSource: (VersionedIndex) -> ShapeEdge?) -> CrossSegment? {
        var s = 1 << power
        var i = s - 1
        let range = xSegment.yRange
        
        while s > 1 {
            s >>= 1
            var j = 0
            while j < self.nodes[i].list.count {
                let seg = self.nodes[i].list[j]
                if seg.xSegment.b.x <= scanPos {
                    self.nodes[i].list.swapRemove(j)
                    continue
                }
                
                if let cross = seg.xSegment.cross(xSegment) {
                    if let shapeEdge = shapeSource(seg.vIndex) {
                        return CrossSegment(index: seg.vIndex, cross: cross, edge: shapeEdge)
                    }
                    
                    self.nodes[i].list.swapRemove(j)
                    self.remove(segment: seg, scanPos: scanPos)
                    continue
                }
                j += 1
            }
        }

        var iLt = i - s
        var iRt = i + s
        
        // for min end
        var e = range.min
        let sm = s

        while s > 1 {
            let middle = nodes[iLt].range.middle
            
            if e == middle {
                break
            }
            
            s >>= 1

            if e < middle {
                iLt -= s
            } else {
                iLt += s
            }
        }

        // for max end
        e = range.max
        s = sm
        
        while s > 1 {
            let middle = nodes[iRt].range.middle
            
            if e == middle {
                break
            }
            
            s >>= 1
            
            if e > middle {
                iRt += s
            } else {
                iRt -= s
            }
        }
        
        i = iLt
        
        while i <= iRt {
            var j = 0
            
            while j < self.nodes[i].list.count {
                let seg = self.nodes[i].list[j]
                if seg.xSegment.b.x <= scanPos {
                    self.nodes[i].list.swapRemove(j)
                    continue
                }
                
                if let cross = seg.xSegment.cross(xSegment) {
                    if let shapeEdge = shapeSource(seg.vIndex) {
                        return CrossSegment(index: seg.vIndex, cross: cross, edge: shapeEdge)
                    }
                    
                    self.nodes[i].list.swapRemove(j)
                    self.remove(segment: seg, scanPos: scanPos)
                    continue
                }
                j += 1
            }
            
            i += 1
        }
        
        return nil
    }
}

private extension Int32 {
    var logTwo: Int {
        Int.bitWidth - self.leadingZeroBitCount
    }
}


private extension LineRange {

    var middle: Int32 {
        self.min + ((self.max - self.min) >> 1)
    }
    
    var logTwo: Int {
        guard self.min < self.max else {
            return 0
        }
        
        return (max - min).logTwo
    }
}


#if DEBUG
extension ScanIntervalTree {
    static func testInitNodes(range: LineRange, power: Int) -> [IntervalNode] {
        ScanIntervalTree.initNodes(range: range, power: power)
    }
    
    func node(index: Int) -> IntervalNode {
        self.nodes[index]
    }
}
#endif
