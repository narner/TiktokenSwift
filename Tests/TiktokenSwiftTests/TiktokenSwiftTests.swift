import XCTest
@testable import TiktokenSwift

final class TiktokenSwiftTests: XCTestCase {
    func testBasicEncoding() throws {
        let encoder = try TiktokenHelper.createTestEncoder()
        let tokens = encoder.encodeText("hello world!")
        XCTAssertEqual(tokens, [0, 2, 1, 3])
        
        let decoded = encoder.decodeTokens(tokens)
        XCTAssertEqual(decoded, "hello world!")
    }
    
    func testSpecialTokens() throws {
        let encoder = try TiktokenHelper.createTestEncoder()
        let specialTokens = encoder.specialTokens()
        XCTAssertEqual(specialTokens, ["<|endoftext|>"])
    }
}
