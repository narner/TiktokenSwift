import Foundation
import XCTest
@testable import TiktokenSwift

/// Helper to download and cache vocabularies for testing
/// Run this once to download all vocabularies to the cache
final class DownloadVocabularies: XCTestCase {
    
    /// Download all vocabularies to cache
    /// This test will download and cache all encodings so subsequent tests can use them
    func testDownloadAllVocabularies() async throws {
        let encodings = [
            "cl100k_base",
            "r50k_base", 
            "p50k_base",
            "o200k_base",
            "gpt2"  // gpt2 uses r50k_base
        ]
        
        for encodingName in encodings {
            do {
                print("📥 Downloading \(encodingName)...")
                let encoder = try await CoreBpe.loadEncoding(named: encodingName == "gpt2" ? "r50k_base" : encodingName)
                
                // Test it works
                let tokens = encoder.encode(text: "test", allowedSpecial: [])
                XCTAssertFalse(tokens.isEmpty)
                
                print("✅ Successfully downloaded and cached \(encodingName)")
            } catch {
                print("❌ Failed to download \(encodingName): \(error)")
                // Don't fail the test - just log the error
            }
        }
    }
    
    /// Helper method to manually download cl100k_base
    func testDownloadCl100kBase() async throws {
        print("📥 Downloading cl100k_base vocabulary...")
        
        let url = URL(string: "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken")!
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Save to cache directory
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("tiktoken", isDirectory: true)
        
        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        
        let cacheFile = cacheDir.appendingPathComponent("cl100k_base.tiktoken")
        try data.write(to: cacheFile)
        
        print("✅ Saved to: \(cacheFile.path)")
        print("📏 File size: \(data.count) bytes")

    }
    
    /// Helper to download all vocabularies directly
    func testDirectDownload() async throws {
        let vocabularies = [
            ("cl100k_base", "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken"),
            ("r50k_base", "https://openaipublic.blob.core.windows.net/encodings/r50k_base.tiktoken"),
            ("p50k_base", "https://openaipublic.blob.core.windows.net/encodings/p50k_base.tiktoken"),
            ("o200k_base", "https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken")
        ]
        
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
            .appendingPathComponent("tiktoken", isDirectory: true)
        
        try FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        
        for (name, urlString) in vocabularies {
            print("📥 Downloading \(name)...")
            
            let url = URL(string: urlString)!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let cacheFile = cacheDir.appendingPathComponent("\(name).tiktoken")
            try data.write(to: cacheFile)
            
            print("✅ Saved \(name) (\(data.count) bytes) to: \(cacheFile.path)")
        }
        
        print("\n✨ All vocabularies downloaded to: \(cacheDir.path)")
    }
}
