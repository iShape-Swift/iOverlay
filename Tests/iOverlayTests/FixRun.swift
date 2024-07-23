/*
import XCTest

import iFixFloat
import iShape
@testable import iOverlay


final class RanTests: XCTestCase {
    
    private let solvers = [
        Solver.list,
        Solver.tree,
        Solver.auto
    ]
    
    func test_00() throws {
        updateTestFiles(in: URL(fileURLWithPath: "/Users/nailsharipov/Projects/Swift_Shape/iOverlay/Tests/iOverlayTests/Overlay_"))
    }
    
    func updateTestFiles(in directory: URL) {
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)

            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            
            for fileURL in fileURLs where fileURL.pathExtension == "json" {
                do {
                    let data = try Data(contentsOf: fileURL)
                    let origin = try JSONDecoder().decode(OverlayTest.self, from: data)

                    var clipSet = Set<Shapes>()
                    var subjectSet = Set<Shapes>()
                    var differenceSet = Set<Shapes>()
                    var inverseDifferenceSet = Set<Shapes>()
                    var intersectSet = Set<Shapes>()
                    var unionSet = Set<Shapes>()
                    var xorSet = Set<Shapes>()
                    
                    for solver in solvers {
                        let overlay = Overlay(subjectPaths: origin.subjPaths, clipPaths: origin.clipPaths)
                        let graph = overlay.buildGraph(fillRule: origin.fillRule, solver: solver)
                        
                        let clip = graph.extractShapes(overlayRule: .clip)
                        let subject = graph.extractShapes(overlayRule: .subject)
                        let difference = graph.extractShapes(overlayRule: .difference)
                        let inverseDifference = graph.extractShapes(overlayRule: .inverseDifference)
                        let intersect = graph.extractShapes(overlayRule: .intersect)
                        let union = graph.extractShapes(overlayRule: .union)
                        let xor = graph.extractShapes(overlayRule: .xor)
                        
                        clipSet.insert(clip)
                        subjectSet.insert(subject)
                        differenceSet.insert(difference)
                        inverseDifferenceSet.insert(inverseDifference)
                        intersectSet.insert(intersect)
                        unionSet.insert(union)
                        xorSet.insert(xor)
                    }

                    let test = OverlayTest(
                        fillRule: origin.fillRule,
                        subjPaths: origin.subjPaths,
                        clipPaths: origin.clipPaths,
                        clip: Array(clipSet),
                        subject: Array(subjectSet),
                        difference: Array(differenceSet),
                        inverseDifference: Array(inverseDifferenceSet),
                        intersect: Array(intersectSet),
                        union: Array(unionSet),
                        xor: Array(xorSet)
                    )

                    let updatedData = try encoder.encode(test)

                    
                    try updatedData.write(to: fileURL)
                    
                    print("Updated \(fileURL.lastPathComponent)")
                } catch {
                    print("Error processing file \(fileURL.lastPathComponent): \(error)")
                }
            }
        } catch {
            print("Error reading directory \(directory.path): \(error)")
        }
    }

}
*/
