//
//  JsonPrint.swift
//
//
//  Created by Nail Sharipov on 15.12.2023.
//

import iShape

struct PrintJson {
    
    static func json(clip: [FixShape], subject: [FixShape], difference: [FixShape], intersect: [FixShape], union: [FixShape], xor: [FixShape], subjPaths: [FixPath], clipPaths: [FixPath]) -> String {
        var result = String()

        result.append("{\n")
        result.append("\"subjPaths\": [\(subjPaths.json())],\n")
        result.append("\"clipPaths\": [\(clipPaths.json())],\n")
        result.append("\"subject\": \(subject.json()),\n")
        result.append("\"clip\": \(clip.json()),\n")
        result.append("\"difference\": \(difference.json()),\n")
        result.append("\"intersect\": \(intersect.json()),\n")
        result.append("\"union\": \(union.json()),\n")
        result.append("\"xor\": \(xor.json())\n")
        result.append("}")
        
        return result
    }
}


extension Array where Element == FixShape {
    
    func json() -> String {
        var result = String()
        if !self.isEmpty {
            result.append("[\n")
            let last = self.count - 1
            for i in 0...last {
                let path = self[i]
                result.append("\n\(path.json())\n")
                if i != last {
                    result.append(",\n")
                }
            }
            result.append("]\n")
        } else {
            result.append("[]\n")
        }
        return result
    }

}

private extension FixShape {
    
    func json() -> String {
        var result = String()
        result.append("    {\n")
        result.append("      \"paths\" : [\n")
        result.append("         \(self.paths.json())")
        result.append("       ]\n")
        result.append("     }")
        
        return result
    }
    
}

extension Array where Element == FixPath {
    func json() -> String {
        if self.isEmpty {
            return ""
        } else {
            var result = String()
            
            let last = self.count - 1
            for i in 0...last {
                let path = self[i]
                result.append("[\n\(path.json())\n]")
                if i != last {
                    result.append(",\n")
                }
            }

            return result
        }
    }
}

private extension FixPath {
    func json() -> String {
        guard !self.isEmpty else {
            return ""
        }
        
        var result = String()
        
        let last = self.count - 1
        for i in 0...last {
            let p = self[i]
            result.append("[\(p.x), \(p.y)]")
            if i != last {
                result.append(",")
            }
        }

        return result
    }
}
