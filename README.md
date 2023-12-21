# iOverlay

<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/balloons.svg" width="250"/>
</p>

The iOverlay is a fast poly-bool library supporting main operations like union, intersection, difference, and XOR, governed by either the even-odd or non-zero rule. This algorithm is based on Vatti clipping ideas but is an original implementation.

## [Documentation](https://ishape-rust.github.io/iShape-js/overlay/stars_demo.html)
Try out iOverlay with an interactive demo. The demo covers operations like union, intersection, difference and exclusion

- [Stars Rotation](https://ishape-rust.github.io/iShape-js/overlay/stars_demo.html)
- [Shapes Editor](https://ishape-rust.github.io/iShape-js/overlay/shapes_editor.html)



## Features

- **Operations**: union, intersection, difference, and exclusion.
- **Polygons**: with holes, self-intersections, and multiple paths.
- **Simplification**: removes degenerate vertices and merges collinear edges.
- **Fill Rules**: even-odd and non-zero.



## Working Range and Precision
The iOverlay library operates within the following ranges and precision levels:

Extended Range: From -1,000,000 to 1,000,000 with a precision of 0.001.
Recommended Range: From -100,000 to 100,000 with a precision of 0.01 for more accurate results.
Utilizing the library within the recommended range ensures optimal accuracy in computations and is advised for most use cases.



## Installation

Installing iOverlay is simple and easy using Swift Package Manager. Just follow these steps:

- Open your Xcode project.
- Select your project and open tab Package Dependencies.
- Click on the "+" button.
- In search bar enter ```https://github.com/iShape-Swift/iOverlay```
- Click the "Add" button.
- Wait for the package to be imported.
- In your Swift code, add the following using statement to access the library:

```swift
import iFixFloat
import iShape
import iOverlay
```



## Usage

Here's an example of how you can create a square with a hole and *union / differnce / intersect / xor* with other polygon:

```swift
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
let union = graph.extractShapes(overlayRule: OverlayRule.union)

// get difference shapes
let difference = graph.extractShapes(overlayRule: OverlayRule.difference)

// get intersect shapes
let intersect = graph.extractShapes(overlayRule: OverlayRule.intersect)

// get exclusion shapes
let xor = graph.extractShapes(overlayRule: OverlayRule.xor)

// get clean shapes from subject, self intersections will be removed
let xor = graph.extractShapes(overlayRule: OverlayRule.subject)
```

### Union
<p align="left">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/union.svg" width="250"/>
</p>

### Difference
<p align="left">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/difference.svg" width="250"/>
</p>

### Intersection
<p align="left">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/intersection.svg" width="250"/>
</p>

### Exclusion (xor)
<p align="left">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/exclusion.svg" width="250"/>
</p>

### Self-intersection
<p align="left">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/self-intersecting.svg" width="250"/>
</p>

