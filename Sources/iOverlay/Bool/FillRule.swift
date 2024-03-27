//
//  FillRule.swift
//
//
//  Created by Nail Sharipov on 29.11.2023.
//

/// Represents the rule used to determine the "hole" of a shape, affecting how shapes are filled. For a visual description, see [Fill Rules](https://ishape-rust.github.io/iShape-js/overlay/filling_rules.html).
/// - `EvenOdd`: A point is part of a hole if a line from that point to infinity crosses an odd number of shape edges.
/// - `NonZero`: A point is part of a hole if the number of left-to-right crossings differs from right-to-left crossings.
public enum FillRule {

    case evenOdd
    case nonZero

}
