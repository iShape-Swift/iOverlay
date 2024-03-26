//
//  ScanSplitTree.swift
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

struct ScanSplitTree: ScanSplitStore {

    fileprivate let power: Int
    fileprivate var nodes: [IntervalNode]

    private static func createNodes(range: LineRange, power: Int) -> [IntervalNode] {
        let n = 1 << power
        
        // to make round more precise we use upscale/downscale
        let scale = 4
        let len = Int(range.max - range.min)
        let step = Int64(Double(len << scale) / Double(n))
        
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
        let maxPowerRange = range.logTwo
        let maxPowerCount = Int32((0.2 * Double(count)).squareRoot()).logTwo
        self.power = min(12, min(maxPowerRange, maxPowerCount))
        nodes = Self.createNodes(range: range, power: power)
    }
    
    init(range: LineRange, power: Int) {
        self.power = power
        self.nodes = Self.createNodes(range: range, power: power)
    }
    
    mutating func insert(segment: VersionSegment) {
        var s = 1 << power
        var i = s - 1
        let range = segment.xSegment.yRange
        
        var earlyOut = false
        
        while s > 1 {
            let middle = self.nodes[i].range.middle
            s >>= 1
            if range.max <= middle {
                i -= s
            } else if range.min >= middle {
                i += s
            } else {
                earlyOut = true
                break
            }
        }
        // at this moment segment is in the middle of node[i]
        if !earlyOut || self.nodes[i].range == range {
            nodes[i].list.append(segment)
            return
        }
        
        let iLt = i - s
        let iRt = i + s

        let sm = s
        
        if range.min == nodes[iLt].range.min {
            assert(!nodes[iLt].list.contains(where: { $0 == segment }))
            nodes[iLt].list.append(segment)
        } else {
            earlyOut = false
            let e = range.min
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
        }

        if range.max == nodes[iRt].range.max {
            assert(!nodes[iRt].list.contains(where: { $0 == segment }))
            nodes[iRt].list.append(segment)
        } else {
            earlyOut = false
            let e = range.max
            var s = sm
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
    }
    
    mutating private func remove(segment: VersionSegment, scanPos: Point) {
        // same logic as for insert but now we remove
        
        var s = 1 << power
        var i = s - 1
        let range = segment.xSegment.yRange
        
        var earlyOut = false
        
        while s > 1 {
            let middle = self.nodes[i].range.middle
            s >>= 1
            if range.max <= middle {
                i -= s
            } else if range.min >= middle {
                i += s
            } else {
                earlyOut = true
                break
            }
        }
        
        // at this moment segment is in the middle of node[i]
        if !earlyOut || self.nodes[i].range == range {
            nodes[i].list.remove(segment: segment, scanPos: scanPos)
            return
        }
        
        let iLt = i - s
        let iRt = i + s
        
        let sm = s
        
        if range.min == nodes[iLt].range.min {
            nodes[iLt].list.remove(segment: segment, scanPos: scanPos)
        } else {
            earlyOut = false
            let e = range.min
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
        }
        
        if range.max == nodes[iRt].range.max {
            nodes[iRt].list.remove(segment: segment, scanPos: scanPos)
        } else {
            earlyOut = false
            let e = range.max
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
    }
    
    mutating func intersect(this: XSegment) -> CrossSegment? {
        var s = 1 << power
        var i = s - 1
        let range = this.yRange
        let scanPos = this.a
        
        var earlyOut = false
        
        while s > 0 {
            if let cross = self.cross(index: i, this: this, scanPos: scanPos) {
                return cross
            }
            s >>= 1
            
            let middle = self.nodes[i].range.middle
            if range.max <= middle {
                i -= s
            } else if range.min >= middle {
                i += s
            } else {
                earlyOut = true
                break
            }
        }

        if !earlyOut {
            // no need more search
            return nil
        }

        let iLt = self.findNode(index: i - s, value: range.min, scale: s)
        let iRt = self.findNode(index: i + s, value: range.max, scale: s)
        
        i = iLt
        
        while i <= iRt {
            if let cross = self.cross(index: i, this: this, scanPos: scanPos) {
                return cross
            }
            i += 1
        }
        
        return nil
    }
    
    mutating func clear() {
        for i in 0..<nodes.count {
            nodes[i].list.removeAll(keepingCapacity: true)
        }
    }
    
    private mutating func cross(index: Int, this: XSegment, scanPos: Point) -> CrossSegment? {
        var j = 0
        
        while j < self.nodes[index].list.count {
            let scan = self.nodes[index].list[j]
            if Point.xLineCompare(a: scan.xSegment.b, b: scanPos) {
                self.nodes[index].list.swapRemove(j)
                continue
            }
            
            // order is important! this x scan
            if let cross = this.cross(scan.xSegment) {
                self.remove(segment: scan, scanPos: scanPos)
                return CrossSegment(index: scan.vIndex, cross: cross)
            }
            j += 1
        }
        
        return nil
    }
    
    private func findNode(index: Int, value: Int32, scale: Int) -> Int {
        var s = scale
        var i = index
        while s > 1 {
            let middle = nodes[i].range.middle
            
            if value == middle {
                return i
            }
            
            s >>= 1
            
            if value < middle {
                i -= s
            } else {
                i += s
            }
        }
        
        return i
    }
    
}

private extension Int32 {
    var logTwo: Int {
        Int32.bitWidth - self.leadingZeroBitCount
    }
}


private extension LineRange {

    var middle: Int32 {
        self.min + ((self.max - self.min) >> 1)
    }
    
    var logTwo: Int {
        (max - min).logTwo
    }
}


#if DEBUG
extension ScanSplitTree {
    static func testInitNodes(range: LineRange, power: Int) -> [IntervalNode] {
        ScanSplitTree.createNodes(range: range, power: power)
    }
    
    func node(index: Int) -> IntervalNode {
        self.nodes[index]
    }
    
    var count: Int {
        var s = 0
        for node in self.nodes {
            s += node.list.count
        }
        return s
    }
}
#endif
