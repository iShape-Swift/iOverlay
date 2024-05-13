//
//  SplitSolverList.swift
//
//
//  Created by Nail Sharipov on 09.05.2024.
//

import iFixFloat

struct SplitSolverList {
    
    var store: StoreList
    
    init(store: StoreList) {
        self.store = store
    }
    
    mutating func split(treeListThreshold: Int) -> Bool {

        var needToFix = true
        
        while needToFix {
            needToFix = false
            
            var this = store.first(index: 0)

        this_loop:
            while this.node != .empty {
                let thisEdge = store.edge(this)

                guard !thisEdge.count.isEmpty else {
                    this = store.removeAndNext(this)
                    continue
                }
                
                var other = store.next(this)
                var i = 0
                
                while other.node != .empty {
                    let otherEdge = store.edge(other)
                    if thisEdge.xSegment.b <= otherEdge.xSegment.a {
                        break
                    }

                    // order is important! thix x scan
                    if let cross = ScanCrossSolver.cross(target: thisEdge.xSegment, other: otherEdge.xSegment) {

                        switch cross {
                        case .pureExact(let point):
                            this = self.pureExact(
                                point: point,
                                i0: this,
                                i1: other
                            )
                        case .pureRound(let point):

                            this = self.pureRound(
                                point: point,
                                i0: this,
                                i1: other
                            )
                            needToFix = true
                            
                        case .otherEndExact(let point):
                            
                            this = self.divideE0Exact(
                                point: point,
                                e0: thisEdge,
                                i0: this
                            )
                            
                        case .otherEndRound(let point):
                            
                            this = self.divideE0Round(
                                point: point,
                                e0: thisEdge,
                                i0: this
                            )
                            
                            needToFix = true
                            
                        case .targetEndExact(let point):

                            self.divideE1Exact(
                                point: point,
                                i1: other
                            )

                        case .targetEndRound(let point):
                            
                            self.divideE1Round(
                                point: point,
                                i1: other
                            )
                            
                            needToFix = true
                            
                        case .endOverlap:
                            // segments are collinear

                            assert(thisEdge.xSegment.a == otherEdge.xSegment.a)
                            assert(thisEdge.xSegment.b < otherEdge.xSegment.b)
    
                            this = self.divideE1Overlap(
                                e0: thisEdge,
                                i1: other
                            )
                            
                        case .overlap:
                            // segments are collinear
                            // 2 situation are possible
                            // other if fully inside this
                            // or
                            // partly overlap each other
                            
                            if thisEdge.xSegment.b < otherEdge.xSegment.b {
                                // partly overlap
                                this = self.divideBothPartlyOverlap(
                                    e0: thisEdge,
                                    i1: other
                                )
                            } else {
                                assert(otherEdge.xSegment.b < thisEdge.xSegment.b)
                                // other inside this
                                this = self.divideE0ByThree(
                                    e0: thisEdge,
                                    i0: this,
                                    e1: otherEdge,
                                    i1: other
                                )
                            }
                        } // switch
                        
                        continue this_loop
                    } // cross
                    
                    other = store.next(other)
                    i += 1
                }

                if i >= treeListThreshold {
                    return false
                }
                
                this = store.next(this)
                
            } // while
        } // while
        
        return true
    }

    private mutating func pureExact(point p: Point, i0: StoreIndex, i1: StoreIndex) -> StoreIndex {
        // classic middle intersection, no ends, overlaps etc

        let e1 = store.getAndRemove(i1)
        let e0 = store.getAndRemove(i0)

        assert(e0.xSegment < e1.xSegment)
        
        let e0Lt = ShapeEdge(xSegment: XSegment(a: e0.xSegment.a, b: p), count: e0.count)
        let e0Rt = ShapeEdge(xSegment: XSegment(a: p, b: e0.xSegment.b), count: e0.count)
        
        assert(e0Lt.xSegment < e0Rt.xSegment)

        let e1Lt = ShapeEdge(xSegment: XSegment(a: e1.xSegment.a, b: p), count: e1.count)
        let e1Rt = ShapeEdge(xSegment: XSegment(a: p, b: e1.xSegment.b), count: e1.count)
        
        assert(e1Lt.xSegment < e1Rt.xSegment)
        
        _ = store.addAndMerge(edge: e1Lt)
        _ = store.addAndMerge(edge: e1Rt)
        
        _ = store.addAndMerge(edge: e0Rt)
        let next = store.addAndMerge(edge: e0Lt)
        
        assert(e0Lt.xSegment.a.x <= p.x)

        assert(!ScanCrossSolver.isValid(scan: e1Rt.xSegment, this: e0Lt.xSegment))
        
        return next
    }
    
    private mutating func pureRound(point p: Point, i0: StoreIndex, i1: StoreIndex) -> StoreIndex {
        // classic middle intersection, no ends, overlaps etc
        
        let e1 = store.getAndRemove(i1)
        let e0 = store.getAndRemove(i0)
        
        assert(e0.xSegment < e1.xSegment)
        
        let e0Lt = ShapeEdge.createAndValidate(a: e0.xSegment.a, b: p, count: e0.count)
        let e0Rt = ShapeEdge.createAndValidate(a: p, b: e0.xSegment.b, count: e0.count)
        
        assert(e0Lt.xSegment < e0Rt.xSegment)
        
        let e1Lt = ShapeEdge.createAndValidate(a: e1.xSegment.a, b: p, count: e1.count)
        let e1Rt = ShapeEdge.createAndValidate(a: p, b: e1.xSegment.b, count: e1.count)
        
        assert(e1Lt.xSegment < e1Rt.xSegment)
        
        _ = store.addAndMerge(edge: e1Lt)
        _ = store.addAndMerge(edge: e1Rt)
        
        _ = store.addAndMerge(edge: e0Rt)
        let next = store.addAndMerge(edge: e0Lt)
        
        assert(e0Lt.xSegment.a.x <= p.x)
        
        return next
    }
    
    private mutating func divideE0Exact(point p: Point, e0: ShapeEdge, i0: StoreIndex) -> StoreIndex {
        
        let e0Lt = ShapeEdge(xSegment: XSegment(a: e0.xSegment.a, b: p), count: e0.count)
        let e0Rt = ShapeEdge(xSegment: XSegment(a: p, b: e0.xSegment.b), count: e0.count)
        
        assert(e0Lt.xSegment < e0Rt.xSegment)

        store.remove(index: i0)
        _ = store.addAndMerge(edge: e0Rt)
        let next = store.addAndMerge(edge: e0Lt)

        return next
    }
    
    private mutating func divideE0Round(point p: Point, e0: ShapeEdge, i0: StoreIndex) -> StoreIndex {

        let e0Lt = ShapeEdge.createAndValidate(a: e0.xSegment.a, b: p, count: e0.count)
        let e0Rt = ShapeEdge.createAndValidate(a: p, b: e0.xSegment.b, count: e0.count)
        
        assert(e0Lt.xSegment < e0Rt.xSegment)

        store.remove(index: i0)
        _ = store.addAndMerge(edge: e0Rt)
        let next = store.addAndMerge(edge: e0Lt)

        return next
    }
    
    private mutating func divideE1Exact(point p: Point, i1: StoreIndex) {
        // this segment-end divide scan(other) segment into 2 parts
        
        let e1 = store.getAndRemove(i1)
        
        let e1Lt = ShapeEdge(xSegment: XSegment(a: e1.xSegment.a, b: p), count: e1.count)
        let e1Rt = ShapeEdge(xSegment: XSegment(a: p, b: e1.xSegment.b), count: e1.count)
        
        assert(e1Lt.xSegment < e1Rt.xSegment)
        
        _ = store.addAndMerge(edge: e1Lt)
        _ = store.addAndMerge(edge: e1Rt)
    }
    
    private mutating func divideE1Round(point p: Point, i1: StoreIndex) {
        // this segment-end divide scan(other) segment into 2 parts
        
        let e1 = store.getAndRemove(i1)
        
        let e1Lt = ShapeEdge.createAndValidate(a: e1.xSegment.a, b: p, count: e1.count)
        let e1Rt = ShapeEdge.createAndValidate(a: p, b: e1.xSegment.b, count: e1.count)
        
        assert(e1Lt.xSegment < e1Rt.xSegment)
        
        _ = store.addAndMerge(edge: e1Lt)
        _ = store.addAndMerge(edge: e1Rt)
    }
    
    private mutating func divideE1Overlap(e0: ShapeEdge, i1: StoreIndex) -> StoreIndex {
        // segments collinear
        // e0.a == e1.a and e0.b < e1.b
        
        let e1 = store.getAndRemove(i1)
        
        let e1Lt = ShapeEdge(xSegment: e0.xSegment, count: e1.count)
        let e1Rt = ShapeEdge(a: e0.xSegment.b, b: e1.xSegment.b, count: e1.count)
        
        _ = store.addAndMerge(edge: e1Rt)
        let next = store.addAndMerge(edge: e1Lt)
        
        return next // same as i0
    }
    
    private mutating func divideBothPartlyOverlap(e0: ShapeEdge, i1: StoreIndex) -> StoreIndex {
        // segments collinear
        // e0.a < e1.a < e0.b < e1.b

        let e1 = store.getAndRemove(i1)
        store.remove(edge: e0)
        
        let e0Lt = ShapeEdge(a: e0.xSegment.a, b: e1.xSegment.a, count: e0.count)
        let middle = ShapeEdge(a: e1.xSegment.a, b: e0.xSegment.b, count: e1.count.add(e0.count))
        let e1Rt = ShapeEdge(a: e0.xSegment.b, b: e1.xSegment.b, count: e1.count)
        
        _ = store.addAndMerge(edge: e1Rt)
        _ = store.addAndMerge(edge: middle)
        let next = store.addAndMerge(edge: e0Lt)
        
        return next
    }
    
    private mutating func divideE0ByThree(e0: ShapeEdge, i0: StoreIndex, e1: ShapeEdge, i1: StoreIndex) -> StoreIndex {
        // segments collinear
        // scan.a < this.a < this.b < scan.b
        
        let e0Lt = ShapeEdge(a: e0.xSegment.a, b: e1.xSegment.a, count: e0.count)
        let merge = e0.count.add(e1.count)
        let e0Rt = ShapeEdge(a: e1.xSegment.b, b: e0.xSegment.b, count: e0.count)
        
        store.update(i1, count: merge)
        
        // indices will be not valid!
        
        store.remove(index: i0)

        _ = store.addAndMerge(edge: e0Rt)
        let next = store.addAndMerge(edge: e0Lt)

        return next
    }
    
}
