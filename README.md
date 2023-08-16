# iOverlay

<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/balloons.svg" width="500"/>
</p>

Poly bool library, which is support main operatioons like union, intersection, difference, xor and self intersection by evenodd rule. An algorithm is based on Vatti clipping ideas but original impementation.

## Features

- Suported operations union, intersection, difference, xor and self intersection

- Supports any kind of polygons self intersected, with holes etc

- All code is written to suit "Data Oriented Design". No reference type like class, just structs.

- Any degenerate case are suported same edge, same points etc
- 
- Any count of overlaps are suported and will be resolved with even odd rule

- Use int math for computation

---

## Basic Usage

Add import:
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
], type: ShapeType.subject)

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

<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/union.svg" width="500"/>
</p>

<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/difference.svg" width="500"/>
</p>

<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/intersection.svg" width="500"/>
</p>

<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/exclusion.svg" width="500"/>
</p>

<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/self-intersecting.svg" width="500"/>
</p>

