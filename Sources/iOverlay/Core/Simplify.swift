//
//  Shape+Simplify.swift
//  
//
//  Created by Nail Sharipov on 18.08.2023.
//

import iShape
import iFixFloat

public extension Path {
    
    func simplify(fillRule: FillRule = .nonZero, minArea: Int64 = 0) -> [Shape] {
        var overlay = Overlay(capacity: self.count)
        overlay.add(path: self, type: .subject)
        return overlay.buildGraph(fillRule: fillRule).extractShapes(overlayRule: .subject, minArea: minArea)
    }
    
}

public extension Shape {
    
    func simplify(fillRule: FillRule = .nonZero, minArea: Int64 = 0) -> [Shape] {
        var overlay = Overlay(capacity: self.pointsCount)
        overlay.add(shape: self, type: .subject)
        return overlay.buildGraph(fillRule: fillRule).extractShapes(overlayRule: .subject, minArea: minArea)
    }
    
}

public extension Array where Element == Shape {
    
    func simplify(fillRule: FillRule = .nonZero, minArea: Int64 = 0) -> [Shape] {
        var overlay = Overlay(capacity: self.pointsCount)
        overlay.add(shapes: self, type: .subject)
        return overlay.buildGraph(fillRule: fillRule).extractShapes(overlayRule: .subject, minArea: minArea)
    }
    
}
