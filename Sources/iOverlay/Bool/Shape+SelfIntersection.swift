//
//  Shape+SelfIntersection.swift
//  
//
//  Created by Nail Sharipov on 18.08.2023.
//

import iShape

public extension FixShape {
    
    func resolveSelfIntersection(minArea: Int64 = 16) -> [FixShape] {
        var overlay = Overlay(capacity: paths.count)
        overlay.add(paths: paths, type: .subject)
        return overlay.buildGraph().extractShapes(fillRule: .subject, minArea: minArea)
    }
    
}
