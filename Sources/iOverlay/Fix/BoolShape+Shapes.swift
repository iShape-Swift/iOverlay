//
//  BoolShape+Fix.swift
//  
//
//  Created by Nail Sharipov on 25.07.2023.
//

import iShape
import iFixFloat

public extension BoolShape {
    
    mutating func shapes() -> [FixPath] {
        
        _ = self.fix()
        self.sortByAngle()
        
        let n = edges.count
        var list = LinkedList(count: n)
        var chains = [ChainPath]()
        var completed = [ChainPath]()

        var i = 0
        
        while i < n {
            let e = edges[i]
            
            let i1 = edges.lastNodeIndex(index: i)
            let len = i1 - i
            
            if len == 1 {
                
                // add new segment or close existed

                var ai = -1
                var bi = -1
                
                var isANext = false
                
                for j in 0..<chains.count {
                    let chain = chains[j]
                    if e.a == chain.nextPoint {
                        ai = j
                        isANext = true
                    } else if e.b == chain.nextPoint {
                        bi = j
                    }
                    
                    if e.a == chain.prevPoint {
                        ai = j
                    } else if e.b == chain.prevPoint {
                        bi = j
                    }
                }
                
                assert(ai >= 0 || bi >= 0)
                
                
                if ai >= 0 && bi >= 0 {
                    
                    // both ends connected
                    
                    if ai == bi {
                        var chain = chains.remove(at: ai)
                        
                        if isANext {
                            chain.close(i, nextPoint: e.a, prevPoint: e.b, list: &list)
                        } else {
                            chain.close(i, nextPoint: e.b, prevPoint: e.a, list: &list)
                        }
                        
                        completed.append(chain)
                    } else if isANext {
                        let prevChain = chains[ai]
                        var nextChain = chains[bi]
                        
                        nextChain.joinToPrev(i, other: prevChain, list: &list)
                        chains[bi] = nextChain
                        
                        chains.remove(at: ai)
                    } else {
                        let nextChain = chains[ai]
                        var prevChain = chains[bi]
                        
                        prevChain.joinToNext(i, other: nextChain, list: &list)
                        chains[ai] = nextChain
                        
                        chains.remove(at: bi)
                    }
                } else {
                    
                    // only a connected
                    
                    assert(bi == -1)
                    var chain = chains[ai]
                    if isANext {
                        chain.joinToNext(i, point: e.b, list: &list)
                    } else {
                        chain.joinToPrev(i, point: e.b, list: &list)
                    }
                    chains[ai] = chain
                }
                
                i += 1

                
            } else {
                
                // start new segments
                
                assert(len % 2 == 0)

                var newChains = [ChainPath]()
                
                while i < i1 {
                    let prev = i
                    i += 1
                    let next = i
                    i += 1
                    
                    let prevPoint = edges[prev].b
                    let nextPoint = edges[next].b
                    
                    let chain = ChainPath(next: next, nextPoint: nextPoint, prev: prev, prevPoint: prevPoint, list: &list)
                    
                    newChains.append(chain)
                }

                // test new first and new last
                
                var j = newChains.count - 1
                while j >= 0 {
                    let chain = newChains[j]
                    if self.join(target: chain, chains: &chains, list: &list) {
                        newChains.remove(at: j)
                    }
                    j -= 1
                }
                
                chains.append(contentsOf: newChains)
            }
        }
        
        
        var paths = [FixPath]()
        for chain in completed {
            let path = chain.path(list: list, edges: edges)
            paths.append(path)
        }
        
        return paths
    }
    
    private struct JoinResult {
        let modified: Bool
        let closed: Int
    }
    
    private func join(target: ChainPath, chains: inout [ChainPath], list: inout LinkedList) -> Bool {
        guard !chains.isEmpty else {
            return false
        }
        
        var iNext = -1
        var iPrev = -1
        
        var isNextToNext = false
        var isPrevToPrev = false
        
        for j in 0..<chains.count {
            let chain = chains[j]
            if chain.nextPoint == target.nextPoint {
                iNext = j
                isNextToNext = true
            } else if chain.prevPoint == target.nextPoint {
                iNext = j
            }
            
            if chain.nextPoint == target.prevPoint {
                iPrev = j
            } else if chain.prevPoint == target.prevPoint {
                iPrev = j
                isPrevToPrev = true
            }
        }
        
        guard iNext >= 0 || iPrev >= 0 else {
            return false
        }

        if iNext >= 0 && iPrev >= 0 {
            
            // both ends are conected

            var result = chains[iNext]
            
            if iNext == iPrev {
                
                // conected to the same chain
                
                assert(isNextToNext)
                assert(isPrevToPrev)

                let iTarget = target.invertedFromPrevToNext(list: &list)
                
                result.joinToNext(other: iTarget, list: &list)
                result.close(list: &list)
            } else {
                
                if isNextToNext {
                    let iTarget = target.invertedFromPrevToNext(list: &list)
                    result.joinToNext(other: iTarget, list: &list)
                    isPrevToPrev = !isPrevToPrev
                } else {
                    result.joinToNext(other: target, list: &list)
                }
                
                if isPrevToPrev {
                    let iTarget = chains[iPrev].invertedFromPrevToNext(list: &list)
                    result.joinToNext(other: iTarget, list: &list)
                } else {
                    result.joinToNext(other: chains[iPrev], list: &list)
                }
                
                chains.remove(at: iPrev)
            }
            
            chains[iNext] = result
        } else if iNext >= 0 {
            var result = chains[iNext]
            if isNextToNext {
                let iTarget = target.invertedFromPrevToNext(list: &list)
                result.joinToNext(other: iTarget, list: &list)
                isPrevToPrev = !isPrevToPrev
            } else {
                result.joinToPrev(other: target, list: &list)
            }
            chains[iNext] = result
        } else {
            var result = chains[iPrev]
            if isPrevToPrev {
                let iTarget = chains[iPrev].invertedFromPrevToNext(list: &list)
                result.joinToPrev(other: iTarget, list: &list)
            } else {
                result.joinToNext(other: chains[iPrev], list: &list)
            }
            
            chains[iPrev] = result
        }
        
        return true
    }
    
}
