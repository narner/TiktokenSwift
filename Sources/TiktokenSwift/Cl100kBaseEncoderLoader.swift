import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

/// Loader for OpenAI encodings that downloads and caches vocabulary data (matching Python implementation)
public struct Cl100kBaseEncoderLoader {
    
    /// URLs for different encodings (matching Python implementation)
    private static let encodingURLs = [
        "cl100k_base": "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken",
        "r50k_base": "https://openaipublic.blob.core.windows.net/encodings/r50k_base.tiktoken",
        "p50k_base": "https://openaipublic.blob.core.windows.net/encodings/p50k_base.tiktoken",
        "o200k_base": "https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken"
    ]
    
    /// Expected hashes for verification (matching Python implementation)
    private static let expectedHashes = [
        "cl100k_base": "223921b76ee99bde995b7ff738513eef100fb51d18c93597a113bcffe865b2a7",
        "r50k_base": "306cd27f03c1a714eca7108e03d66b7dc042abe8c258b44c199a7ed9838dd930",
        "p50k_base": "94b5ca7dff4d00767bc256fdd1b27e5b17361d7b8a5f968547f9f23eb70d2069",
        "o200k_base": "446a9538cb6c348e3516120d7c08b09f57c36495e2acfffe59a5bf8b0cfb1a2d"
    ]
    
    /// Special tokens for different encodings
    private static let specialTokens: [String: [String: UInt32]] = [
        "cl100k_base": [
            "<|endoftext|>": 100257,
            "<|fim_prefix|>": 100258,
            "<|fim_middle|>": 100259,
            "<|fim_suffix|>": 100260,
            "<|endofprompt|>": 100276
        ],
        "r50k_base": [
            "<|endoftext|>": 50256
        ],
        "p50k_base": [
            "<|endoftext|>": 50256
        ],
        "o200k_base": [
            "<|endoftext|>": 199999,
            "<|endofprompt|>": 200018
        ]
    ]
    
    /// Patterns for different encodings
    private static let patterns: [String: String] = [
        "cl100k_base": "'(?i:[sdmt]|ll|ve|re)|[^\\r\\n\\p{L}\\p{N}]?+\\p{L}++|\\p{N}{1,3}+| ?[^\\s\\p{L}\\p{N}]++[\\r\\n]*+|\\s++$|\\s*[\\r\\n]|\\s+(?!\\S)|\\s",
        "r50k_base": "'(?:[sdmt]|ll|ve|re)| ?\\p{L}++| ?\\p{N}++| ?[^\\s\\p{L}\\p{N}]++|\\s++$|\\s+(?!\\S)|\\s",
        "p50k_base": "'(?:[sdmt]|ll|ve|re)| ?\\p{L}++| ?\\p{N}++| ?[^\\s\\p{L}\\p{N}]++|\\s++$|\\s+(?!\\S)|\\s",
        "o200k_base": "[^\\r\\n\\p{L}\\p{N}]?[\\p{Lu}\\p{Lt}\\p{Lm}\\p{Lo}\\p{M}]*[\\p{Ll}\\p{Lm}\\p{Lo}\\p{M}]+(?i:'s|'t|'re|'ve|'m|'ll|'d)?|[^\\r\\n\\p{L}\\p{N}]?[\\p{Lu}\\p{Lt}\\p{Lm}\\p{Lo}\\p{M}]+[\\p{Ll}\\p{Lm}\\p{Lo}\\p{M}]*(?i:'s|'t|'re|'ve|'m|'ll|'d)?|\\p{N}{1,3}| ?[^\\s\\p{L}\\p{N}]+[\\r\\n/]*|\\s*[\\r\\n]+|\\s+(?!\\S)|\\s+"
    ]
    
    /// Cache directory for storing downloaded vocabularies
    private static var cacheDirectory: URL {
        let documentsPath = FileManager.default.urls(for: .cachesDirectory, 
                                                     in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("tiktoken", isDirectory: true)
    }
    
    /// Load an encoder for the specified encoding name
    public static func loadEncoder(named encodingName: String) async throws -> CoreBpe {
        // Check if we have a cached version
        let cacheURL = cacheDirectory.appendingPathComponent("\(encodingName).tiktoken")
        
        if FileManager.default.fileExists(atPath: cacheURL.path) {
            print("📂 Loading cached \(encodingName) from: \(cacheURL.path)")
            return try await loadFromFile(cacheURL, encodingName: encodingName)
        }
        
        // Download if not cached
        guard let urlString = encodingURLs[encodingName],
              let url = URL(string: urlString) else {
            throw LoadError.unsupportedEncoding(encodingName)
        }
        
        print("⬇️  Downloading \(encodingName) from: \(url)")
        
        // Create cache directory if needed
        try FileManager.default.createDirectory(at: cacheDirectory, 
                                               withIntermediateDirectories: true)
        
        // Download the data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Verify hash if available
        #if canImport(CryptoKit)
        if let expectedHash = expectedHashes[encodingName] {
            let hash = SHA256.hash(data: data)
            let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
            
            if hashString != expectedHash {
                throw LoadError.hashMismatch(expected: expectedHash, actual: hashString)
            }
            print("✅ Hash verified")
        }
        #endif
        
        // Save to cache
        try data.write(to: cacheURL)
        print("💾 Saved to cache: \(cacheURL.path)")
        
        // Load and return
        return try await loadFromData(data, encodingName: encodingName)
    }
    
    /// Load encoder from cached file
    private static func loadFromFile(_ url: URL, encodingName: String) async throws -> CoreBpe {
        let data = try Data(contentsOf: url)
        return try await loadFromData(data, encodingName: encodingName)
    }
    
    /// Load encoder from data
    private static func loadFromData(_ data: Data, encodingName: String) async throws -> CoreBpe {
        // Parse the tiktoken format (which is a custom binary format)
        let mergeableRanks = try parseTiktokenBpe(data)
        
        // Get special tokens and pattern for this encoding
        let specialTokens = self.specialTokens[encodingName] ?? [:]
        let pattern = patterns[encodingName] ?? patterns["cl100k_base"]!
        
        print("📊 Loaded \(encodingName):")
        print("   Vocabulary size: \(mergeableRanks.count)")
        print("   Special tokens: \(specialTokens.count)")
        
        // Create the encoder
        return try newCoreBpe(
            encoder: mergeableRanks,
            specialTokensEncoder: specialTokens,
            pattern: pattern
        )
    }
    
    /// Parse tiktoken BPE format
    /// The format is: base64-encoded token followed by space and rank
    private static func parseTiktokenBpe(_ data: Data) throws -> [String: UInt32] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw LoadError.invalidData
        }
        
        var encoder: [String: UInt32] = [:]
        
        // Split by lines and parse each line
        let lines = content.split(separator: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            
            // Each line has format: "base64_token rank"
            let parts = trimmed.split(separator: " ", maxSplits: 1)
            guard parts.count == 2,
                  let rank = UInt32(parts[1]) else {
                continue
            }
            
            // Decode the base64 token
            guard let tokenData = Data(base64Encoded: String(parts[0])) else {
                continue
            }
            
            // For tokens that are valid UTF-8, store as string
            // For non-UTF8 tokens, we need special handling
            if let tokenString = String(data: tokenData, encoding: .utf8) {
                encoder[tokenString] = rank
            } else {
                // For non-UTF8 sequences, we'll need to handle them specially
                // This matches our uniffi_bindings.rs implementation
                let base64String = "base64:" + tokenData.base64EncodedString()
                encoder[base64String] = rank
            }
        }
        
        return encoder
    }
    
    /// Clear the cache directory
    public static func clearCache() throws {
        if FileManager.default.fileExists(atPath: cacheDirectory.path) {
            try FileManager.default.removeItem(at: cacheDirectory)
        }
    }
    
    /// Get cache size in bytes
    public static func cacheSize() -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for case let fileURL as URL in enumerator {
            if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
    
    /// Errors that can occur during loading
    public enum LoadError: LocalizedError {
        case unsupportedEncoding(String)
        case downloadFailed(Error)
        case invalidData
        case hashMismatch(expected: String, actual: String)
        
        public var errorDescription: String? {
            switch self {
            case .unsupportedEncoding(let name):
                return "Unsupported encoding: \(name)"
            case .downloadFailed(let error):
                return "Download failed: \(error.localizedDescription)"
            case .invalidData:
                return "Invalid tiktoken data format"
            case .hashMismatch(let expected, let actual):
                return "Hash mismatch - expected: \(expected), actual: \(actual)"
            }
        }
    }
}

// Convenience extension
public extension CoreBpe {
    /// Load a standard OpenAI encoding by name
    static func loadEncoding(named name: String) async throws -> CoreBpe {
        return try await Cl100kBaseEncoderLoader.loadEncoder(named: name)
    }
    
    /// Load cl100k_base encoding (most common)
    static func cl100kBase() async throws -> CoreBpe {
        return try await loadEncoding(named: "cl100k_base")
    }
    
    /// Load r50k_base encoding
    static func r50kBase() async throws -> CoreBpe {
        return try await loadEncoding(named: "r50k_base")
    }
    
    /// Load p50k_base encoding
    static func p50kBase() async throws -> CoreBpe {
        return try await loadEncoding(named: "p50k_base")
    }
    
    /// Load o200k_base encoding
    static func o200kBase() async throws -> CoreBpe {
        return try await loadEncoding(named: "o200k_base")
    }
}