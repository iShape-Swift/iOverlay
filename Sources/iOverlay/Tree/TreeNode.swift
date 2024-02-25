//
//  TreeNode.swift
//  StrTree
//
//  Created by Nail Sharipov on 24.02.2024.
//

enum NodeColor: UInt8 {
    case red
    case black
}

struct TreeNode<T> {
    
    let index: UInt32
    var parent: UInt32
    
    var left: UInt32
    var right: UInt32
    
    var color: NodeColor
    
    var value: T
    
}

extension UInt32 {
    static let empty = UInt32.max
}
