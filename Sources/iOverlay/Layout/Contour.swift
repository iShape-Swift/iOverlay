//
//  Contour.swift
//  
//
//  Created by Nail Sharipov on 27.07.2023.
//

import iShape
import iFixFloat

struct Contour {
    let path: FixPath       // Array of points in clockwise order
    let boundary: FixBnd    // Smallest bounding box of the path
    let start: FixVec       // Leftmost point in the path
    let isCavity: Bool      // True if path is an internal cavity (hole), false if external (hull)
}
