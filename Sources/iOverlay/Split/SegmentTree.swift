//
//  SegmentTree.swift
//  
//
//  Created by Nail Sharipov on 06.03.2024.
//

import iFixFloat
import iTree

struct IntervalNode {
    let range: LineRange
    var fragments: [Fragment]
}

extension IntervalNode {
    init(range: LineRange) {
        self.range = range
        self.fragments = [Fragment]()
        self.fragments.reserveCapacity(4)
    }
}

extension IntRect {
    var yRange: LineRange {
        LineRange(min: self.minY, max: self.maxY)
    }
}

struct SegmentTree {

    private let power: Int
    fileprivate var nodes: [IntervalNode]

    private static func createNodes(range: LineRange, power: Int) -> [IntervalNode] {
        let n = 1 << power
        
        // to make round more precise we use upscale/downscale
        let scale = 4
        let len = range.width
        let step = (len << scale) / Int64(n)
        
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
    
    init(range: LineRange, power: Int) {
        self.power = power
        self.nodes = Self.createNodes(range: range, power: power)
    }
    
    mutating func insert(fragment: Fragment) {
        var s = 1 << power
        var i = s - 1
        let range = fragment.rect.yRange
        
        var earlyOut = false
        
        while s > 1 {
            let middle = self.nodes[i].range.middle
            s >>= 1
            if range.max < middle {
                i -= s
            } else if range.min > middle {
                i += s
            } else {
                earlyOut = true
                break
            }
        }
        // at this moment segment is in the middle of node[i]
        if !earlyOut || self.nodes[i].range == range {
            nodes[i].fragments.append(fragment)
            return
        }
        
        let iLt = i - s
        let iRt = i + s

        let sm = s
        
        if range.min == nodes[iLt].range.min {
            nodes[iLt].fragments.append(fragment)
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
                    nodes[rt].fragments.append(fragment)
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
                nodes[i].fragments.append(fragment)
            }
        }

        if range.max == nodes[iRt].range.max {
            nodes[iRt].fragments.append(fragment)
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
                    nodes[lt].fragments.append(fragment)
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
                nodes[i].fragments.append(fragment)
            }
        }
    }
    
    mutating func intersect(this: Fragment, marks: inout [LineMark]) -> Bool {
        var s = 1 << power
        var i = s - 1
        let range = this.rect.yRange
        
        var earlyOut = false
        var anyRound = false
        
        while s > 0 {
            let isRound = self.crossNode(index: i, this: this, marks: &marks)
            anyRound = isRound || anyRound
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
            return anyRound
        }

        // find most left index
        
        var j = i - s
        var sj = s
        while sj > 1 {
            let isRound = self.crossNode(index: j, this: this, marks: &marks)
            anyRound = isRound || anyRound
            
            let middle = nodes[j].range.middle
            
            if range.min == middle {
                break
            }
            
            sj >>= 1
            
            if range.min < middle {
                j -= sj
            } else {
                j += sj
            }
        }
        
        // find most right index
        
        let iLt = j
        
        j = i + s
        sj = s
        while sj > 1 {
            let isRound = self.crossNode(index: j, this: this, marks: &marks)
            anyRound = isRound || anyRound
            
            let middle = nodes[j].range.middle
            
            if range.max == middle {
                break
            }
            
            sj >>= 1
            
            if range.max < middle {
                j -= sj
            } else {
                j += sj
            }
        }

        let iRt = j
        
        i = iLt
        
        while i <= iRt {
            let isRound = self.crossNode(index: i, this: this, marks: &marks)
            anyRound = isRound || anyRound
            i += 1
        }
        
        return anyRound
    }
    
    mutating func clear() {
        for i in 0..<nodes.count {
            nodes[i].fragments.removeAll(keepingCapacity: true)
        }
    }
    
    private mutating func crossNode(index: Int, this: Fragment, marks: inout [LineMark]) -> Bool {
        
        let swipeLine = this.rect.minX
        var anyRound = false
        
        var j = 0
        while j < self.nodes[index].fragments.count {
            let scan = self.nodes[index].fragments[j]
            
            guard scan.rect.maxX >= swipeLine else {
                // remove item if it outside
                self.nodes[index].fragments.swapRemove(j)
                continue
            }

            j += 1
            
            guard scan.rect.isIntersectBorderInclude(this.rect) else {
                continue
            }
            
            let isRound = SplitSolver.cross(
                i: this.index,
                j: scan.index,
                ei: this.xSegment,
                ej: scan.xSegment,
                marks: &marks
            )
            
            anyRound = isRound || anyRound
        }
        
        return anyRound
    }
    
}

private extension LineRange {

    var middle: Int32 {
        (self.max + self.min) >> 1
    }
}

#if DEBUG
extension SegmentTree {
    static func testInitNodes(range: LineRange, power: Int) -> [IntervalNode] {
        SegmentTree.createNodes(range: range, power: power)
    }
    
    func node(index: Int) -> IntervalNode {
        self.nodes[index]
    }
    
    var count: Int {
        var s = 0
        for node in self.nodes {
            s += node.fragments.count
        }
        return s
    }
}
#endif
