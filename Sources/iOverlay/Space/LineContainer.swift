//
//  LineContainer.swift
//
//
//  Created by Nail Sharipov on 02.01.2024.
//

public struct LineContainer<Id> {
    public let id: Id
    public let index: DualIndex
    
    public init(id: Id, index: DualIndex) {
        self.id = id
        self.index = index
    }
}
