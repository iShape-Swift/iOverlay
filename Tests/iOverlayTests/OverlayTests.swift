import XCTest
import iShape
import iFixFloat
@testable import iOverlay

extension FixShape: Equatable {
    public static func == (lhs: FixShape, rhs: FixShape) -> Bool {
        lhs.paths == rhs.paths
    }
}

final class OverlayTests: XCTestCase {
    
    private let solvers = [
        Solver(
            strategy: .list,
            chunkStartLength: 8,
            chunkListMaxSize: 256
        ),
        Solver(
            strategy: .list,
            chunkStartLength: 8,
            chunkListMaxSize: 16
        ),
        Solver(
            strategy: .tree,
            chunkStartLength: 16,
            chunkListMaxSize: 32
        ),
        Solver(
            strategy: .auto,
            chunkStartLength: 2,
            chunkListMaxSize: 4
        ),
        Solver(
            strategy: .auto,
            chunkStartLength: 1,
            chunkListMaxSize: 2
        )
    ]
    
    
    private func execute(index: Int) {
        let test = OverlayTestBank.load(index: index)
        let overlay = Overlay(subjectPaths: test.subjPaths, clipPaths: test.clipPaths)
        
        for solver in solvers {
            let graph = overlay.buildGraph(fillRule: test.fillRule, solver: solver)
            
            let clip = graph.extractShapes(overlayRule: .clip)
            let subject = graph.extractShapes(overlayRule: .subject)
            let difference = graph.extractShapes(overlayRule: .difference)
            let intersect = graph.extractShapes(overlayRule: .intersect)
            let union = graph.extractShapes(overlayRule: .union)
            let xor = graph.extractShapes(overlayRule: .xor)
            
//            self.printTest(test, clip: clip, subject: subject, difference: difference, intersect: intersect, union: union, xor: xor)
            
            XCTAssertTrue(self.test(result: clip, bank: test.clip))
            XCTAssertTrue(self.test(result: subject, bank: test.subject))
            XCTAssertTrue(self.test(result: difference, bank: test.difference))
            XCTAssertTrue(self.test(result: intersect, bank: test.intersect))
            XCTAssertTrue(self.test(result: union, bank: test.union))
            XCTAssertTrue(self.test(result: xor, bank: test.xor))
        }
    }
    
    private func printTest(_ test: OverlayTest, clip: [Shape], subject: [Shape], difference: [Shape], intersect: [Shape], union: [Shape], xor: [Shape]) {
        let aTest = OverlayTest(
            fillRule: test.fillRule,
            subjPaths: test.subjPaths,
            clipPaths: test.clipPaths,
            clip: [clip],
            subject: [subject],
            difference: [difference],
            intersect: [intersect],
            union: [union],
            xor: [xor]
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(aTest)
            if let json = String(data: data, encoding: .utf8) {
                print(json)
            }
        } catch {
            print("Error converting to JSON: \(error)")
        }
        
    }
    
    
    private func debugExecute(index: Int, overlayRule: OverlayRule, solver: Solver) {
        let test = OverlayTestBank.load(index: index)
        let overlay = Overlay(subjectPaths: test.subjPaths, clipPaths: test.clipPaths)
        let graph = overlay.buildGraph(fillRule: test.fillRule, solver: solver)
        let result = graph.extractShapes(overlayRule: overlayRule)
        
        print("result: \(result)")
    }
    
    func test(result: [Shape], bank: [[Shape]]) -> Bool {
        for item in bank {
            if item == result {
                return true
            }
        }
        return false
    }
    
    func test_00() throws {
        self.execute(index: 0)
    }
    
    func test_01() throws {
        self.execute(index: 1)
    }
    
    func test_02() throws {
        self.execute(index: 2)
    }
    
    func test_03() throws {
        self.execute(index: 3)
    }
    
    func test_04() throws {
        self.execute(index: 4)
    }
    
    func test_05() throws {
        self.execute(index: 5)
    }
    
    func test_06() throws {
        self.execute(index: 6)
    }
    
    func test_07() throws {
        self.execute(index: 7)
    }

    func test_08() throws {
        self.execute(index: 8)
    }
    
    func test_09() throws {
        self.execute(index: 9)
    }
    
    func test_10() throws {
        self.execute(index: 10)
    }
    
    func test_11() throws {
        self.execute(index: 11)
    }
    
    func test_12() throws {
        self.execute(index: 12)
    }
    
    func test_13() throws {
        self.execute(index: 13)
    }
    
    func test_14() throws {
        self.execute(index: 14)
    }
    
    func test_15() throws {
        self.execute(index: 15)
    }
    
    func test_16() throws {
        self.execute(index: 16)
    }
    
    func test_17() throws {
        self.execute(index: 17)
    }
    
    func test_18() throws {
        self.execute(index: 18)
    }
    
    func test_19() throws {
        self.execute(index: 19)
    }
    
    func test_20() throws {
        self.execute(index: 20)
    }
    
    func test_21() throws {
        self.execute(index: 21)
    }
    
    func test_22() throws {
        self.execute(index: 22)
    }
    
    func test_23() throws {
        self.execute(index: 23)
    }
    
    func test_24() throws {
        self.execute(index: 24)
    }
    
    func test_25() throws {
        self.execute(index: 25)
    }
    
    func test_26() throws {
        self.execute(index: 26)
    }
    
    func test_27() throws {
        self.execute(index: 27)
    }
    
    func test_28() throws {
        self.execute(index: 28)
    }
    
    func test_29() throws {
        self.execute(index: 29)
    }
    
    func test_30() throws {
        self.execute(index: 30)
    }
    
    func test_31() throws {
        self.execute(index: 31)
    }
    
    func test_32() throws {
        self.execute(index: 32)
    }
    
    func test_33() throws {
        self.execute(index: 33)
    }
    
    func test_34() throws {
        self.execute(index: 34)
    }
    
    func test_35() throws {
        self.execute(index: 35)
    }
    
    func test_36() throws {
        self.execute(index: 36)
    }
    
    func test_37() throws {
        self.execute(index: 37)
    }
    
    func test_38() throws {
        self.execute(index: 38)
    }
    
    func test_39() throws {
        self.execute(index: 39)
    }
    
    func test_40() throws {
        self.execute(index: 40)
    }
    
    func test_41() throws {
        self.execute(index: 41)
    }
    
    func test_42() throws {
        self.execute(index: 42)
    }
    
    func test_43() throws {
        self.execute(index: 43)
    }
    
    func test_44() throws {
        self.execute(index: 44)
    }
    
    func test_45() throws {
        self.execute(index: 45)
    }
    
    func test_46() throws {
        self.execute(index: 46)
    }
    
    func test_47() throws {
        self.execute(index: 47)
    }
    
    func test_48() throws {
        self.execute(index: 48)
    }
    
    func test_49() throws {
        self.execute(index: 49)
    }
    
    func test_50() throws {
        self.execute(index: 50)
    }
    
    func test_51() throws {
        self.execute(index: 51)
    }
    
    func test_52() throws {
        self.execute(index: 52)
    }
    
    func test_53() throws {
        self.execute(index: 53)
    }
    
    func test_54() throws {
        self.execute(index: 54)
    }
    
    func test_55() throws {
        self.execute(index: 55)
    }
    
    func test_56() throws {
        self.execute(index: 56)
    }
    
    func test_57() throws {
        self.execute(index: 57)
    }
    
    func test_58() throws {
        self.execute(index: 58)
    }
    
    func test_59() throws {
        self.execute(index: 59)
    }
    
    func test_60() throws {
        self.execute(index: 60)
    }
    
    func test_61() throws {
        self.execute(index: 61)
    }
    
    func test_62() throws {
        self.execute(index: 62)
    }
    
    func test_63() throws {
        self.execute(index: 63)
    }
    
    func test_64() throws {
        self.execute(index: 64)
    }
    
    func test_65() throws {
        self.execute(index: 65)
    }
    
    func test_66() throws {
        self.execute(index: 66)
    }
    
    func test_67() throws {
        self.execute(index: 67)
    }
    
    func test_68() throws {
        self.execute(index: 68)
    }
    
    func test_69() throws {
        self.execute(index: 69)
    }

    func test_70() throws {
        self.execute(index: 70)
    }
    
    func test_71() throws {
        self.execute(index: 71)
    }
    
    func test_72() throws {
        self.execute(index: 72)
    }
    
    func test_73() throws {
        self.execute(index: 73)
    }
    
    func test_74() throws {
        self.execute(index: 74)
    }
    
    func test_75() throws {
        self.execute(index: 75)
    }
    
    func test_76() throws {
        self.execute(index: 76)
    }
    
    func test_77() throws {
        self.execute(index: 77)
    }
    
    func test_78() throws {
        self.execute(index: 78)
    }
    
    func test_79() throws {
        self.execute(index: 79)
    }

    func test_80() throws {
        self.execute(index: 80)
    }
    
    func test_81() throws {
        self.execute(index: 81)
    }
    
    func test_82() throws {
        self.execute(index: 82)
    }
    
    func test_83() throws {
        self.execute(index: 83)
    }
    
    func test_84() throws {
        self.execute(index: 84)
    }
    
    func test_85() throws {
        self.execute(index: 85)
    }
    
    func test_86() throws {
        self.execute(index: 86)
    }
    
    func test_87() throws {
        self.execute(index: 87)
    }
    
    func test_88() throws {
        self.execute(index: 88)
    }
    
    func test_89() throws {
        self.execute(index: 89)
    }
    
    func test_90() throws {
        self.execute(index: 90)
    }
    
    func test_91() throws {
        self.execute(index: 91)
    }
    
    func test_92() throws {
        self.execute(index: 92)
    }
    
    func test_93() throws {
        self.execute(index: 93)
    }
    
    func test_94() throws {
        self.execute(index: 94)
    }
    
    func test_95() throws {
        self.execute(index: 95)
    }
    
    func test_96() throws {
        self.execute(index: 96)
    }
    
    func test_97() throws {
        self.execute(index: 97)
    }
    
    func test_98() throws {
        self.execute(index: 98)
    }
    
    func test_99() throws {
        self.execute(index: 99)
    }
    
    func test_100() throws {
        self.execute(index: 100)
    }
    
    func test_101() throws {
        self.execute(index: 101)
    }
    
    func test_102() throws {
        self.execute(index: 102)
    }
    
    func test_103() throws {
        self.execute(index: 103)
    }
    
    func test_104() throws {
        self.execute(index: 104)
    }
    
    func test_105() throws {
        self.execute(index: 105)
    }
    
    func test_106() throws {
        self.execute(index: 106)
    }
    
    func test_107() throws {
        self.execute(index: 107)
    }
    
    func test_108() throws {
        self.execute(index: 108)
    }
    
    func test_109() throws {
        self.execute(index: 109)
    }
    
    func test_110() throws {
        self.execute(index: 110)
    }
    
    func test_111() throws {
        self.execute(index: 111)
    }
    
    func test_112() throws {
        self.execute(index: 112)
    }
    
    func test_113() throws {
        self.execute(index: 113)
    }
    
    func test_114() throws {
        self.execute(index: 114)
    }
    
    func test_115() throws {
        self.execute(index: 115)
    }
    
    func test_116() throws {
        self.execute(index: 116)
    }
    
    func test_117() throws {
        self.execute(index: 117)
    }
    
    func test_118() throws {
        self.execute(index: 118)
    }
    
    func test_119() throws {
        self.execute(index: 119)
    }
    
    func test_120() throws {
        self.execute(index: 120)
    }
    
    func test_121() throws {
        self.execute(index: 121)
    }
    
    func test_debug() throws {
        self.debugExecute(index: 2, overlayRule: .union, solver: self.solvers[0])
    }
}
