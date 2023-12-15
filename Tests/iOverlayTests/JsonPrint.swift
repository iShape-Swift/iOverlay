//
//  JsonPrint.swift
//
//
//  Created by Nail Sharipov on 15.12.2023.
//

import iShape

extension Array where Element == FixShape {
    
    func json() -> String {
        var result = String()
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

private extension FixPath {
    func json() -> String {
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
