import XCTest
import BigIntCompress

extension Int: BigIntType {
    
    public var hexString: String {
        return String(self, radix: 16)
    }
    
    public init?(hexString: String) {
        var integer: UInt64 = 0
        let scanner = Scanner(string: hexString)
        scanner.scanHexInt64(&integer)
        self = Int(exactly: integer)!
        
    }
    
    public init<T>(_ value: T) where T : Numeric {
        self = value as! Int
    }
}

extension String: Compressable {
    public typealias CompressionNumber = Int
    
    public static var possibleComponents: [Character] {
        return [ "A", "C", "G", "T" ]
    }
    
    public static func single(_ element: Element) -> String {
        return "\(element)"
    }
}
class BigIntCompressTests: XCTestCase {
    func testExample() {
       let expected = "ACGT"
        
        let compressed = expected.bic.encode()
        let back = try! String.bic.decode(compressed!)!
        
        XCTAssert(back == expected)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
