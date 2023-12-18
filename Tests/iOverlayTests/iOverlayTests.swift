import XCTest
import iShape
import iFixFloat
@testable import iOverlay

extension FixShape: Equatable {
    public static func == (lhs: FixShape, rhs: FixShape) -> Bool {
        lhs.paths == rhs.paths
    }
}

final class iOverlayTests: XCTestCase {
    
    private func execute(index: Int) {
        let test = OverlayTestBank.load(index: index)

        var overlay = Overlay()
        overlay.add(paths: test.subjPaths, type: .subject)
        overlay.add(paths: test.clipPaths, type: .clip)
        
        let graph = overlay.buildGraph(fillRule: .evenOdd)
        
        let clip = graph.extractShapes(overlayRule: .clip)
        let subject = graph.extractShapes(overlayRule: .subject)
        let difference = graph.extractShapes(overlayRule: .difference)
        let intersect = graph.extractShapes(overlayRule: .intersect)
        let union = graph.extractShapes(overlayRule: .union)
        let xor = graph.extractShapes(overlayRule: .xor)

        
//        print(PrintJson.json(clip: clip, subject: subject, difference: difference, intersect: intersect, union: union, xor: xor, subjPaths: test.subjPaths, clipPaths: test.clipPaths))
        
        XCTAssertEqual(test.clip, clip)
        XCTAssertEqual(test.subject, subject)
        XCTAssertEqual(test.difference, difference)
        XCTAssertEqual(test.intersect, intersect)
        XCTAssertEqual(test.union, union)
        XCTAssertEqual(test.xor, xor)
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
}
