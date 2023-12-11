//
//  Shape+SelfIntersection.swift
//  
//
//  Created by Nail Sharipov on 18.08.2023.
//

import iShape

public extension FixShape {
    
    func resolveSelfIntersection(fillRule: FillRule = .nonZero, minArea: Int64 = 0) -> [FixShape] {
        var overlay = Overlay(capacity: paths.count)
        overlay.add(paths: paths, type: .subject)
        return overlay.buildGraph(fillRule: fillRule).extractShapes(overlayRule: .subject, minArea: minArea)
    }
    
}
