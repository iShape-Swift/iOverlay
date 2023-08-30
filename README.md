# iOverlay

<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/balloons.svg" width="250"/>
</p>

The iOverlay is a poly-bool library that supports main operations such as union, intersection, difference, xor, and self-intersection by the even-odd rule. This algorithm is based on Vatti clipping ideas but is an original implementation.

## Demo
Try out iOverlay with an interactive demo. The demo covers operations like union, intersection, and difference.
[Demo](https://ishape-rust.github.io/i_shape_js/demo/stars_demo.html)



## Features

- Supports all basic set operations such as union, intersection, difference, exclusion, and self-intersection.
- Capable of handling various types of polygons, including self-intersecting polygons, multiple paths, and polygons with holes.
- Optimizes by removing unnecessary vertices and merging parallel edges.
- Effectively handles an arbitrary number of overlaps, resolving them using the even-odd rule.
- Employs integer arithmetic for computations.



## Working Range and Precision
The iOverlay library operates within the following ranges and precision levels:

Extended Range: From -1,000,000 to 1,000,000 with a precision of 0.001.
Recommended Range: From -100,000 to 100,000 with a precision of 0.01 for more accurate results.
Utilizing the library within the recommended range ensures optimal accuracy in computations and is advised for most use cases.



## Basic Usage

Add the following imports:
```swift
import iFixFloat
import iShape
import iOverlay

var overlay = Overlay()

// add shape
overlay.add(path: [
    Vec(-20, -16).fix,
    Vec(-20,  16).fix,
    Vec( 20,  16).fix,
    Vec( 20, -16).fix
], type: ShapeType.subject)

// add hole
overlay.add(path: [
    Vec(-12, -8).fix,
    Vec(-12,  8).fix,
    Vec( 12,  8).fix,
    Vec( 12, -8).fix
], type: ShapeType.subject)

// add clip
overlay.add(path: [
    Vec(-4, -24).fix,
    Vec(-4,  24).fix,
    Vec( 4,  24).fix,
    Vec( 4, -24).fix
], type: ShapeType.clip)

// make overlay graph
let graph = overlay.buildGraph()

// get union shapes
let union = graph.extractShapes(fillRule: FillRule.union)

// get difference shapes
let difference = graph.extractShapes(fillRule: FillRule.difference)

// get intersect shapes
let intersect = graph.extractShapes(fillRule: FillRule.intersect)

// get exclusion shapes
let xor = graph.extractShapes(fillRule: FillRule.xor)

// get clean shapes from subject, self intersections will be removed
let xor = graph.extractShapes(fillRule: FillRule.subject)
```

### Union
<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/union.svg" width="500"/>
</p>

### Difference
<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/difference.svg" width="500"/>
</p>

### Intersection
<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/intersection.svg" width="500"/>
</p>

### Exclusion (xor)
<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/exclusion.svg" width="500"/>
</p>

### Self-intersection
<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/self-intersecting.svg" width="500"/>
</p>

