# iOverlay

<p align="center">
<img src="https://github.com/iShape-Swift/iOverlay/blob/main/Readme/balloons.svg" width="250"/>
</p>

The iOverlay is a fast poly-bool library supporting main operations like union, intersection, difference, and xor, governed by either the even-odd or non-zero rule.  
This library is optimized for different scenarios, ensuring high performance across various use cases. For detailed performance benchmarks, check out the [Performance Comparison](https://ishape-rust.github.io/iShape-js/overlay/performance/performance.html)

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
import iOverlay
```



## Usage

Here's an example of how you can create a square with a hole and *union / differnce / intersect / xor* with other polygon:

```swift
var overlay = CGOverlay()

// add shape
overlay.add(path: [
    CGPoint(x:-20, y:-16),
    CGPoint(x:-20, y: 16),
    CGPoint(x: 20, y: 16),
    CGPoint(x: 20, y:-16)
], type: ShapeType.subject)

// add hole
overlay.add(path: [
    CGPoint(x:-12, y:-8),
    CGPoint(x:-12, y: 8),
    CGPoint(x: 12, y: 8),
    CGPoint(x: 12, y:-8)
], type: ShapeType.subject)

// add clip
overlay.add(path: [
    CGPoint(x:-4, y:-24),
    CGPoint(x:-4, y: 24),
    CGPoint(x: 4, y: 24),
    CGPoint(x: 4, y:-24)
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
let subject = graph.extractShapes(overlayRule: OverlayRule.subject)
```

### Shapes result

The output of the `extractShapes` function is a `[[[CGPoint]]]`, where:

- The outer `[CGShape]` represents a set of shapes.
- Each shape `[CGPath]` represents a collection of paths, where the first path is the outer boundary, and all subsequent paths are holes in this boundary.
- Each path `[CGPoint]` is a sequence of points, forming a closed path.

**Note**: Outer boundary paths have a clockwise order, and holes have a counterclockwise order.

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

