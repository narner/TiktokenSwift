import XCTest
@testable import TiktokenSwift

final class TiktokenSwiftTests: XCTestCase {
    
    // MARK: - Setup
    
    override class func setUp() {
        super.setUp()
        // Download vocabularies once for all tests
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            await downloadVocabulariesIfNeeded()
            semaphore.signal()
        }
        semaphore.wait()
    }
    
    /// Download vocabularies if not already cached
    static func downloadVocabulariesIfNeeded() async {
        let vocabularies = [
            ("cl100k_base", "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken"),
            ("r50k_base", "https://openaipublic.blob.core.windows.net/encodings/r50k_base.tiktoken"),
            ("p50k_base", "https://openaipublic.blob.core.windows.net/encodings/p50k_base.tiktoken"),
            ("o200k_base", "https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken")
        ]
        
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("tiktoken", isDirectory: true)
        
        // Check if already downloaded
        var needsDownload = false
        for (name, _) in vocabularies {
            let cacheFile = cacheDir.appendingPathComponent("\(name).tiktoken")
            if !FileManager.default.fileExists(atPath: cacheFile.path) {
                needsDownload = true
                break
            }
        }
        
        guard needsDownload else {
            print("✅ Vocabularies already cached")
            return
        }
        
        print("📥 Downloading vocabularies...")
        
        do {
            try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
            
            for (name, urlString) in vocabularies {
                let cacheFile = cacheDir.appendingPathComponent("\(name).tiktoken")
                
                // Skip if already exists
                if FileManager.default.fileExists(atPath: cacheFile.path) {
                    print("✅ \(name) already cached")
                    continue
                }
                
                print("⬇️  Downloading \(name)...")
                let url = URL(string: urlString)!
                let (data, _) = try await URLSession.shared.data(from: url)
                try data.write(to: cacheFile)
                print("✅ Downloaded \(name) (\(data.count) bytes)")
            }
        } catch {
            print("⚠️ Error downloading vocabularies: \(error)")
        }
    }
    
    // MARK: - Tests with Real Encodings
    
    func testCl100kBase() async throws {
        let encoder = try await CoreBpe.cl100kBase()
        
        // Test known token values for cl100k_base
        XCTAssertEqual(encoder.encode(text: "hello world", allowedSpecial: []), [15339, 1917])
        XCTAssertEqual(encoder.encode(text: "", allowedSpecial: []), [])
        XCTAssertEqual(encoder.encode(text: " ", allowedSpecial: []), [220])
        
        // Test special tokens
        XCTAssertEqual(encoder.encode(text: "hello <|endoftext|>", allowedSpecial: ["<|endoftext|>"]), [15339, 220, 100257])
        
        // Test regex patterns
        XCTAssertEqual(encoder.encode(text: "rer", allowedSpecial: []), [38149])
        XCTAssertEqual(encoder.encode(text: "'rer", allowedSpecial: []), [2351, 81])
        XCTAssertEqual(encoder.encode(text: "today\n ", allowedSpecial: []), [31213, 198, 220])
        
        // Test emoji
        XCTAssertEqual(encoder.encode(text: "👍", allowedSpecial: []), [9468, 239, 235])
        
        // Test roundtrip
        let text = "The quick brown fox jumps over the lazy dog."
        let tokens = encoder.encode(text: text, allowedSpecial: [])
        let decoded = String(data: Data(try encoder.decodeBytes(tokens: tokens)), encoding: .utf8)
        XCTAssertEqual(decoded, text)
    }
    
    func testR50kBase() async throws {
        let encoder = try await CoreBpe.r50kBase()
        
        // Test known token values
        XCTAssertEqual(encoder.encode(text: "hello world", allowedSpecial: []), [31373, 995])
        
        // Test roundtrip
        let text = "Testing r50k_base encoding"
        let tokens = encoder.encode(text: text, allowedSpecial: [])
        let decoded = String(data: Data(try encoder.decodeBytes(tokens: tokens)), encoding: .utf8)
        XCTAssertEqual(decoded, text)
    }
    
    func testP50kBase() async throws {
        let encoder = try await CoreBpe.p50kBase()
        
        // Test known token values
        XCTAssertEqual(encoder.encode(text: "hello world", allowedSpecial: []), [31373, 995])
        
        // Test roundtrip
        let text = "Testing p50k_base encoding"
        let tokens = encoder.encode(text: text, allowedSpecial: [])
        let decoded = String(data: Data(try encoder.decodeBytes(tokens: tokens)), encoding: .utf8)
        XCTAssertEqual(decoded, text)
    }
    
    func testGPT2() async throws {
        // GPT-2 uses r50k_base encoding
        let encoder = try await CoreBpe.loadEncoding(named: "r50k_base")
        
        // Test known token values for GPT-2
        XCTAssertEqual(encoder.encode(text: "hello world", allowedSpecial: []), [31373, 995])
        XCTAssertEqual(encoder.encode(text: "hello <|endoftext|>", allowedSpecial: ["<|endoftext|>"]), [31373, 220, 50256])
        
        // Test repeated zeros 
        XCTAssertEqual(encoder.encode(text: "0", allowedSpecial: []), [15])
        XCTAssertEqual(encoder.encode(text: "00", allowedSpecial: []), [405])
        XCTAssertEqual(encoder.encode(text: "000", allowedSpecial: []), [830])
        XCTAssertEqual(encoder.encode(text: "0000", allowedSpecial: []), [2388])
        XCTAssertEqual(encoder.encode(text: "00000", allowedSpecial: []), [20483])
        XCTAssertEqual(encoder.encode(text: "000000", allowedSpecial: []), [10535])
        XCTAssertEqual(encoder.encode(text: "0000000", allowedSpecial: []), [24598])
        XCTAssertEqual(encoder.encode(text: "00000000", allowedSpecial: []), [8269])
    }
    
    func testO200kBase() async throws {
        do {
            let encoder = try await CoreBpe.o200kBase()
            
            // Test basic functionality
            let text = "Testing o200k_base encoding"
            let tokens = encoder.encode(text: text, allowedSpecial: [])
            XCTAssertFalse(tokens.isEmpty)
            
            // Test roundtrip
            let decoded = String(data: Data(try encoder.decodeBytes(tokens: tokens)), encoding: .utf8)
            XCTAssertEqual(decoded, text)
        } catch {
            // o200k_base might not be available in all versions
            throw XCTSkip("o200k_base not available: \(error)")
        }
    }
    
    // MARK: - Cross-Encoding Comparison Tests
    
    func testEncodingComparison() async throws {
        let text = "The quick brown fox jumps over the lazy dog."
        
        let cl100k = try await CoreBpe.cl100kBase()
        let r50k = try await CoreBpe.r50kBase()
        let p50k = try await CoreBpe.p50kBase()
        
        let cl100kTokens = cl100k.encode(text: text, allowedSpecial: [])
        let r50kTokens = r50k.encode(text: text, allowedSpecial: [])
        let p50kTokens = p50k.encode(text: text, allowedSpecial: [])
        
        // r50k and p50k should produce the same tokens for basic text
        XCTAssertEqual(r50kTokens, p50kTokens)
        
        // cl100k should be different (more efficient)
        XCTAssertNotEqual(cl100kTokens, r50kTokens)
        
        // cl100k should generally use fewer tokens
        XCTAssertLessThanOrEqual(cl100kTokens.count, r50kTokens.count)
        
        print("Token counts for '\(text)':")
        print("  cl100k_base: \(cl100kTokens.count) tokens")
        print("  r50k_base:   \(r50kTokens.count) tokens")
        print("  p50k_base:   \(p50kTokens.count) tokens")
    }
    
    // MARK: - Special Token Tests
    
    func testSpecialTokens() async throws {
        let encoder = try await CoreBpe.cl100kBase()
        
        let text = "Hello <|endoftext|> World"
        
        // Without allowing special tokens (should encode the literal text)
        let withoutSpecial = encoder.encodeOrdinary(text: text)
        
        // With special tokens allowed
        let withSpecial = encoder.encode(text: text, allowedSpecial: ["<|endoftext|>"])
        
        // These should be different
        XCTAssertNotEqual(withoutSpecial, withSpecial)
        
        // The version with special tokens should contain token 100257 (endoftext)
        XCTAssertTrue(withSpecial.contains(100257))
        XCTAssertFalse(withoutSpecial.contains(100257))
    }
    
    // MARK: - Catastrophic Repetition Test
    
    func testCatastrophicallyRepetitive() async throws {
        let encoder = try await CoreBpe.cl100kBase()
        
        let testChars = ["^", "0", "a", "'s", " ", "\n"]
        
        for char in testChars {
            // Test with large repetition
            let bigValue = String(repeating: char, count: 10000)
            let tokens = encoder.encode(text: bigValue, allowedSpecial: [])
            let decoded = String(data: Data(try encoder.decodeBytes(tokens: tokens)), encoding: .utf8)
            XCTAssertEqual(decoded, bigValue, "Failed for repeated: \(char)")
            
            // Test with space prefix
            let withPrefix = " " + bigValue
            let tokensPrefix = encoder.encode(text: withPrefix, allowedSpecial: [])
            let decodedPrefix = String(data: Data(try encoder.decodeBytes(tokens: tokensPrefix)), encoding: .utf8)
            XCTAssertEqual(decodedPrefix, withPrefix, "Failed with prefix for: \(char)")
            
            // Test with newline suffix
            let withSuffix = bigValue + "\n"
            let tokensSuffix = encoder.encode(text: withSuffix, allowedSpecial: [])
            let decodedSuffix = String(data: Data(try encoder.decodeBytes(tokens: tokensSuffix)), encoding: .utf8)
            XCTAssertEqual(decodedSuffix, withSuffix, "Failed with suffix for: \(char)")
        }
    }
    
    // MARK: - International Text Tests
    
    func testInternationalText() async throws {
        let encoder = try await CoreBpe.cl100kBase()
        
        let testCases = [
            "请考试我的软件！12345",
            "こんにちは世界",
            "مرحبا بالعالم",
            "Здравствуй, мир",
            "Bonjour le monde",
            "🚀🌍🎉"
        ]
        
        for text in testCases {
            let tokens = encoder.encode(text: text, allowedSpecial: [])
            let decoded = String(data: Data(try encoder.decodeBytes(tokens: tokens)), encoding: .utf8)
            XCTAssertEqual(decoded, text, "Roundtrip failed for: \(text)")
        }
    }
    
    // MARK: - Edge Cases
    
    func testEdgeCases() async throws {
        let encoder = try await CoreBpe.cl100kBase()
        
        // Empty string
        XCTAssertEqual(encoder.encode(text: "", allowedSpecial: []), [])
        
        // Single space
        XCTAssertEqual(encoder.encode(text: " ", allowedSpecial: []), [220])
        
        // Newline
        XCTAssertEqual(encoder.encode(text: "\n", allowedSpecial: []), [198])
        
        // Tab
        let tabTokens = encoder.encode(text: "\t", allowedSpecial: [])
        XCTAssertFalse(tabTokens.isEmpty)
        
        // Mixed whitespace
        let whitespace = " \t\n\r"
        let wsTokens = encoder.encode(text: whitespace, allowedSpecial: [])
        let wsDecoded = String(data: Data(try encoder.decodeBytes(tokens: wsTokens)), encoding: .utf8)
        XCTAssertEqual(wsDecoded, whitespace)
    }
    
    // MARK: - Performance Tests
    
    func testEncodingPerformance() async throws {
        let encoder = try await CoreBpe.cl100kBase()
        let text = String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 1000)
        
        measure {
            _ = encoder.encode(text: text, allowedSpecial: [])
        }
    }
    
    func testDecodingPerformance() async throws {
        let encoder = try await CoreBpe.cl100kBase()
        let text = String(repeating: "The quick brown fox jumps over the lazy dog. ", count: 1000)
        let tokens = encoder.encode(text: text, allowedSpecial: [])
        
        measure {
            _ = try? encoder.decodeBytes(tokens: tokens)
        }
    }
    
    // MARK: - Thread Safety
    
    func testConcurrentEncoding() async throws {
        let encoder = try await CoreBpe.cl100kBase()
        let expectation = XCTestExpectation(description: "Concurrent encoding")
        let iterations = 100
        expectation.expectedFulfillmentCount = iterations
        
        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            let text = "Concurrent test \(i)"
            let tokens = encoder.encode(text: text, allowedSpecial: [])
            if let decoded = try? encoder.decodeBytes(tokens: tokens),
               let decodedText = String(data: Data(decoded), encoding: .utf8) {
                XCTAssertEqual(decodedText, text)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
}
