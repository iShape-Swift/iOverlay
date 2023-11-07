//
//  OverlayTestBank.swift
//
//
//  Created by Nail Sharipov on 07.11.2023.
//

import iShape
import iFixFloat
import Foundation
import simd
@testable import iOverlay

struct OverlayTest: Decodable {
    let subjPaths: [[FixVec]]
    let clipPaths: [[FixVec]]
    let clip: [FixShape]
    let subject: [FixShape]
    let difference: [FixShape]
    let intersect: [FixShape]
    let union: [FixShape]
    let xor: [FixShape]

    enum CodingKeys: String, CodingKey {
        case subjPaths
        case clipPaths
        case clip
        case subject
        case difference
        case intersect
        case union
        case xor
    }
}

extension FixShape: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let paths = try container.decode([FixPath].self, forKey: .paths)
        self.init(paths: paths)
    }
    
    enum CodingKeys: String, CodingKey {
        case paths
    }
}

struct OverlayTestBank {
    
    static func load(index: Int) -> OverlayTest {
        let bundle = Bundle.module
        
        if let fileURL = bundle.url(forResource: "test_\(index)", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileURL)

                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(OverlayTest.self, from: data)
                
                return decodedData
            } catch {
                print("Error loading resource: \(error)")
            }
        }
        
        fatalError("Error loading test file: \(index)")
    }
}

