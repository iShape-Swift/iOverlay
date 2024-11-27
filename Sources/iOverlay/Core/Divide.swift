//
//  Divide.swift
//  iOverlay
//
//  Created by Nail Sharipov on 27.11.2024.
//

import iShape
import iFixFloat

private struct SubPath {
    var last: Int
    var node: Point
    var path: [Point]

    static func start(point: IdPoint) -> SubPath {
        return SubPath(last: point.id + 1, node: point.point, path: [point.point])
    }

    mutating func join(point: IdPoint, source: [Point]) {
        path.append(contentsOf: source[last..<point.id])
        last = point.id
    }

    mutating func shift(point: IdPoint) {
        last = point.id
    }
}


public extension Path {
 
    func decomposeContours() -> [Path]? {
        guard self.count >= 3 else {
            return nil
        }

        var idPoints = self.enumerated().map { IdPoint(id: $0.offset, point: $0.element) }

        idPoints.sort {
            if $0.point != $1.point {
                return $0.point < $1.point
            }
            return $0.id < $1.id
        }

        var p0 = idPoints.first!.point
        var anchors = [IdPoint]()
        var n = 0

        for (i, idp) in idPoints.enumerated().dropFirst() {
            if p0 == idp.point {
                n += 1
                continue
            }

            if n > 0 {
                anchors.append(contentsOf: idPoints[(i - n - 1)..<i])
                n = 0
            }

            p0 = idp.point
        }

        if anchors.isEmpty {
            return nil
        }

        anchors.sort { $0.id < $1.id }

        var contours = [Path]()
        var queue = [SubPath]()
        var i = 0

        while i < anchors.count {
            let a = anchors[i]

            guard var subPath = queue.popLast() else {
                queue.append(SubPath.start(point: a))
                i += 1
                continue
            }

            if subPath.node == a.point {
                subPath.join(point: a, source: self)
                contours.append(subPath.path)

                if queue.isEmpty {
                    queue.append(SubPath.start(point: a))
                } else {
                    queue[queue.count - 1].shift(point: a)
                }
            } else {
                subPath.join(point: a, source: self)
                queue.append(subPath)
                queue.append(SubPath.start(point: a))
            }

            i += 1
        }

        var lastSubPath = queue.popLast()!

        if lastSubPath.last < self.count {
            lastSubPath.path.append(contentsOf: self[lastSubPath.last..<self.count])
        }

        let i0 = anchors.first!.id
        if i0 > 0 {
            lastSubPath.path.append(contentsOf: self[0..<i0])
        }

        contours.append(lastSubPath.path)

        return contours
    }
    
}

public extension Shape {
    
    mutating func decomposeContours() {
        let n = self.count
        for i in 0..<n {
            let path = self[i]
            guard let contours = path.decomposeContours() else { continue }
            self[i] = contours[0]
            for j in 1..<contours.count {
                self.append(contours[j])
            }
        }
    }
}

public extension Shapes {
    
    mutating func decomposeContours() {
        let n = self.count
        for i in 0..<n {
            self[i].decomposeContours()
        }
    }
}
