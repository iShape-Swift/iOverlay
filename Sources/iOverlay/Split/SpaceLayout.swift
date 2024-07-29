//
//  SpaceLayout.swift
//  
//
//  Created by Nail Sharipov on 20.07.2024.
//

import iFixFloat

struct SpaceLayout {

    private static let minPower = 2
    private static let maxPower = 12
    static let minRangeLength = 1 << minPower
    private let scale: Int
    let power: Int
    let minSize: UInt64
    
    init(range: LineRange, count: Int) {
        let maxPowerRange = range.logTwo - 1
        let maxPowerCount = Int64(count).logTwo >> 1
        let originalPower = min(maxPowerRange, maxPowerCount)
        self.power = max(Self.minPower, min(Self.maxPower, originalPower))
        self.minSize = UInt64(range.width >> self.power)
        let m = Int64(self.minSize).logTwo
        self.scale = UInt32.bitWidth - m
    }
   
}

extension SpaceLayout {
    
    func breakIntoFragments(index: Int, xSegment: XSegment, buffer: inout [Fragment]) {
        let minX = xSegment.a.x
        let maxX = xSegment.b.x
        
        let isUp = xSegment.a.y < xSegment.b.y
        
        let minY: Int32
        let maxY: Int32
        
        if isUp {
            minY = xSegment.a.y
            maxY = xSegment.b.y
        } else {
            minY = xSegment.b.y
            maxY = xSegment.a.y
        }

        let dx = UInt64(Int64(maxX) - Int64(minX))
        let dy = UInt64(Int64(maxY) - Int64(minY))
        
        let isFragmentationRequired = dx > self.minSize && dy > self.minSize
        
        guard isFragmentationRequired else {
            buffer.append(Fragment(index: index, xSegment: xSegment))
            return
        }

        let k = (dy << self.scale) / dx
        
        let s: UInt64
        if dx < dy {
            s = self.minSize << self.scale
        } else {
            s = (self.minSize << self.scale) * dx / dy
        }
        
        var x0: UInt64 = 0

        var ix0 = minX
        var iy0 = isUp ? minY : maxY
        
        let xLast = (dx << self.scale) - s
        
        guard x0 < xLast else {
            return
        }
        
        while x0 < xLast {
            let x1 = x0 + s
            let x = x1 >> self.scale
            
            let y1 = x * k
            let y = y1 >> self.scale

            let isSameLine = x * dy == y * dx
            let extra: Int32 = isSameLine ? 0 : 1
            
            let ix1 = minX + Int32(x)
            
            let rect: IntRect
            let iy1: Int32
            if isUp {
                iy1 = minY + Int32(y)
                rect = IntRect(minX: ix0, maxX: ix1, minY: iy0, maxY: iy1 + extra)
            } else {
                iy1 = maxY - Int32(y)
                rect = IntRect(minX: ix0, maxX: ix1, minY: iy1 - extra, maxY: iy0)
            }

            buffer.append(Fragment(index: index, rect: rect, xSegment: xSegment))
            
            x0 = x1
            
            ix0 = ix1
            iy0 = iy1
        }
        
        let rect: IntRect
        if isUp {
            rect = IntRect(minX: ix0, maxX: maxX, minY: iy0, maxY: maxY)
        } else {
            rect = IntRect(minX: ix0, maxX: maxX, minY: minY, maxY: iy0)
        }
        buffer.append(Fragment(index: index, rect: rect, xSegment: xSegment))
    }
    
    private func isFragmentationRequired(xSegment: XSegment) -> Bool {
        let dx = UInt64(Int64(xSegment.b.x) - Int64(xSegment.a.x))
        let dy = UInt64(abs(Int64(xSegment.b.x) - Int64(xSegment.a.x)))
        
        return dx > self.minSize && dy > self.minSize
    }
    
    func isFragmentationRequired(edges: [ShapeEdge]) -> Bool {
        var i = 0
        for edge in edges {
            if self.isFragmentationRequired(xSegment: edge.xSegment) {
                i += 1
            }
        }
        // must be at least 20%
        return i * 20 > edges.count
    }
    
}

private extension Int64 {
    var logTwo: Int {
        Int64.bitWidth - self.leadingZeroBitCount
    }
}

private extension LineRange {
    var logTwo: Int {
        self.width.logTwo
    }
}

private extension Int64 {
    func divideAndRoundUp(_ value: Int64) -> Int64 {
        (self + value - 1) / value
    }
}
