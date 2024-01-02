//
//  LineSegment.swift
//  
//
//  Created by Nail Sharipov on 02.01.2024.
//

public struct LineSegment<Id> {
    public let id: Id
    public let range: LineRange
    
    public init(id: Id, range: LineRange) {
        self.id = id
        self.range = range
    }
}
