import Foundation
import XCTest
@testable import TiktokenSwift

/// Helper to download and cache encodings for tests
struct TestEncodingHelper {
    
    /// Pre-download and cache encodings for testing
    /// This helps tests run consistently without network issues during test execution
    static func setupEncodingsIfNeeded() async throws {
        // Try to download and cache common encodings
        // These will be cached in ~/Library/Caches/tiktoken/
        
        let encodingsToCache = [
            "cl100k_base",
            "gpt2",
            "r50k_base",
            "p50k_base"
        ]
        
        for encoding in encodingsToCache {
            do {
                print("📥 Attempting to cache \(encoding)...")
                _ = try await CoreBpe.loadEncoding(named: encoding)
                print("✅ Successfully cached \(encoding)")
            } catch {
                print("⚠️ Could not cache \(encoding): \(error)")
                // Continue with other encodings
            }
        }
    }
    
    /// Load cl100k_base from a local test file (if we have one)
    static func loadCl100kBaseFromTestData() throws -> CoreBpe? {
        // Check if we have a local test data file
        let bundle = Bundle(for: TiktokenSwiftTests.self)
        
        // Try to find a test data file in the test bundle
        if let testDataURL = bundle.url(forResource: "cl100k_base", withExtension: "tiktoken") {
            print("📂 Loading cl100k_base from test data: \(testDataURL.path)")
            return try EncodingLoader.loadEncoding(from: testDataURL.path)
        }
        
        return nil
    }
    
    /// Try to get an encoding, falling back to test encoder if needed
    static func getEncodingOrTestEncoder(named name: String) async throws -> CoreBpe {
        do {
            return try await CoreBpe.loadEncoding(named: name)
        } catch {
            print("⚠️ Could not load \(name), using test encoder instead")
            return try TiktokenHelper.createTestEncoder()
        }
    }
}

/// XCTest extension to set up encodings once per test session
extension XCTestCase {
    
    /// Call this in setUpWithError() to ensure encodings are cached
    func setupEncodingsOnce() async throws {
        // Use a static flag to only download once per test session
        struct Static {
            static var hasSetup = false
        }
        
        guard !Static.hasSetup else { return }
        Static.hasSetup = true
        
        try await TestEncodingHelper.setupEncodingsIfNeeded()
    }
}