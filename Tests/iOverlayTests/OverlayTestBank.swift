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
    let fillRule: FillRule
    let subjPaths: [[FixVec]]
    let clipPaths: [[FixVec]]
    let clip: [FixShape]
    let subject: [FixShape]
    let difference: [FixShape]
    let intersect: [FixShape]
    let union: [FixShape]
    let xor: [FixShape]

    enum CodingKeys: String, CodingKey {
        case fillRule
        case subjPaths
        case clipPaths
        case clip
        case subject
        case difference
        case intersect
        case union
        case xor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Custom decoding for fillRule
        if let fillRuleValue = try? container.decode(Int.self, forKey: .fillRule) {
            switch fillRuleValue {
            case 0:
                fillRule = FillRule.evenOdd
            case 1:
                fillRule = FillRule.nonZero
            default:
                fillRule = FillRule.evenOdd
            }
        } else {
            fillRule = FillRule.evenOdd
        }
        
        subjPaths = try container.decode([[FixVec]].self, forKey: .subjPaths)
        clipPaths = try container.decode([[FixVec]].self, forKey: .clipPaths)
        clip = try container.decode([FixShape].self, forKey: .clip)
        subject = try container.decode([FixShape].self, forKey: .subject)
        difference = try container.decode([FixShape].self, forKey: .difference)
        intersect = try container.decode([FixShape].self, forKey: .intersect)
        union = try container.decode([FixShape].self, forKey: .union)
        xor = try container.decode([FixShape].self, forKey: .xor)
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

extension FixShape {
    
    func compare(_ other: FixShape) -> Bool {
        guard self.paths.count == other.paths.count else {
            return false
        }
        
        for i in 0..<paths.count {
            if self.compare(other.paths, shift: i) {
                return true
            }
        }
        
        return false
    }
    
    
    func compare(_ other: [FixPath], shift: Int) -> Bool {
        let n = paths.count
        for i in 0..<n {
            let a0 = paths[i]
            let a1 = other[(i + shift) % n]
            if !a0.compare(a1) {
                return false
            }
        }
        return true
    }

}

extension Array where Element == FixShape {
    
    func compare(_ other: [FixShape]) -> Bool {
        guard self.count == other.count else {
            return false
        }
        for i in 0..<count {
            if self.compare(other, shift: i) {
                return true
            }
        }
        
        return false
    }
    
    func compare(_ other: [FixShape], shift: Int) -> Bool {
        let n = self.count
        for i in 0..<n {
            let a0 = self[i]
            let a1 = other[(i + shift) % n]
            if !a0.compare(a1) {
                return false
            }
        }
        return true
    }

}

extension FixPath {
    
    func compare(_ other: FixPath) -> Bool {
        guard self.count == other.count else {
            return false
        }
        for i in 0..<count {
            if self.compare(other, shift: i) {
                return true
            }
        }
        
        return false
    }
    
    func compare(_ other: FixPath, shift: Int) -> Bool {
        let n = self.count
        for i in 0..<n {
            let a0 = self[i]
            let a1 = other[(i + shift) % n]
            if a0 != a1 {
                return false
            }
        }
        return true
    }

}
