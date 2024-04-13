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
    let subjPaths: [[Point]]
    let clipPaths: [[Point]]
    let clip: [[Shape]]
    let subject: [[Shape]]
    let difference: [[Shape]]
    let intersect: [[Shape]]
    let union: [[Shape]]
    let xor: [[Shape]]

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
        
        subjPaths = try container.decode([[Point]].self, forKey: .subjPaths)
        clipPaths = try container.decode([[Point]].self, forKey: .clipPaths)
        clip = try container.decode([[Shape]].self, forKey: .clip)
        subject = try container.decode([[Shape]].self, forKey: .subject)
        difference = try container.decode([[Shape]].self, forKey: .difference)
        intersect = try container.decode([[Shape]].self, forKey: .intersect)
        union = try container.decode([[Shape]].self, forKey: .union)
        xor = try container.decode([[Shape]].self, forKey: .xor)
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

extension Shape {
    
    func compare(_ other: Shape) -> Bool {
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
    
    
    func compare(_ other: [Path], shift: Int) -> Bool {
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

extension Array where Element == Shape {
    
    func compare(_ other: [Shape]) -> Bool {
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
    
    func compare(_ other: [Shape], shift: Int) -> Bool {
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

extension Path {
    
    func compare(_ other: Path) -> Bool {
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
    
    func compare(_ other: Path, shift: Int) -> Bool {
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

#if DEBUG

extension OverlayTest: Encodable {
    
    init(
        fillRule: FillRule,
        subjPaths: [[Point]],
        clipPaths: [[Point]],
        clip: [[Shape]],
        subject: [[Shape]],
        difference: [[Shape]],
        intersect: [[Shape]],
        union: [[Shape]],
        xor: [[Shape]]
    ) {
        self.fillRule = fillRule
        self.subjPaths = subjPaths
        self.clipPaths = clipPaths
        self.clip = clip
        self.subject = subject
        self.difference = difference
        self.intersect = intersect
        self.union = union
        self.xor = xor
    }
}

extension FillRule: Encodable {
    public func encode(to encoder: any Encoder) throws {
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
             switch self {
             case .evenOdd:
                 try container.encode(0)
             case .nonZero:
                 try container.encode(1)
             }
        }
    }
}


#endif
