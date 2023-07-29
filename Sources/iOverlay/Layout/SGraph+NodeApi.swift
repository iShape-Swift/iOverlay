//
//  SGraph+NodeApi.swift
//  
//
//  Created by Nail Sharipov on 27.07.2023.
//

import iFixFloat
import iShape

extension SGraph {
    
    func findNearestLinkTo(target: IndexPoint, center: IndexPoint, ignore: Int, inClockWise: Bool, visited: [Bool]) -> Int {
        let node = nodes[center.index]

        // find any not visited vector
        
        var i = node.data0
        let last = i + node.count

        var minIndex = -1
        
        while i < last {
            let j = indices[i]
            if !visited[j] && ignore != j {
                minIndex = j
                break
            }
            i += 1
        }
        
        guard minIndex >= 0 else {
            return -1
        }
        
        var minVec = links[minIndex].other(center).point - center.point
        let v0 = target.point - center.point // base vector
        
        // compare minVec with the rest of the vectors
        
        i += 1
        while i < last {
            let j = indices[i]
            if !visited[j] && ignore != j {
                let vj = links[j].other(center).point - center.point
                
                if v0.isCloserInRotation(to: vj, comparedTo: minVec) == inClockWise {
                    minVec = vj
                    minIndex = j
                }
                
            }
            i += 1
        }
        
        
        return minIndex
    }
}

private extension FixVec {
    
    // v, a, b vectors are multidirectional
    func isCloserInRotation(to a: FixVec, comparedTo b: FixVec) -> Bool {
        let crossA = self.unsafeCrossProduct(a)
        let crossB = self.unsafeCrossProduct(b)

        guard crossA != 0 && crossB != 0 else {
            // vectors are collinear
            if crossA == 0 {
                // a is opposite to self, so based on crossB
                return crossB > 0
            } else {
                // b is opposite to self, so based on crossA
                return crossA < 0
            }
        }
        
        let sameSide = crossA > 0 && crossB > 0 || crossA < 0 && crossB < 0
        
        guard sameSide else {
            return crossA < 0
        }

        let crossAB = a.unsafeCrossProduct(b)
        
        return crossAB < 0
    }

}
