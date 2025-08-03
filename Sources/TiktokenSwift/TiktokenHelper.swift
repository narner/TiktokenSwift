import Foundation

/// Helper utilities for using Tiktoken
public struct TiktokenHelper {
    /// Creates a test encoder with a small vocabulary
    /// - Note: This is for testing only. In production, load real encoding data.
    public static func createTestEncoder() throws -> CoreBpe {
        let encoder: [String: UInt32] = [
            "hello": 0,
            "world": 1,
            " ": 2,
            "!": 3,
            "test": 4,
            "swift": 5,
            "tiktoken": 6,
            "the": 7,
            "quick": 8,
            "brown": 9,
            "fox": 10
        ]
        let specialTokens: [String: UInt32] = ["<|endoftext|>": 100257]
        let pattern = "'(?i:[sdmt]|ll|ve|re)|[^\\r\\n\\p{L}\\p{N}]?+\\p{L}++|\\p{N}{1,3}+| ?[^\\s\\p{L}\\p{N}]++[\\r\\n]*+|\\s++$|\\s*[\\r\\n]|\\s+(?!\\S)|\\s"
        
        return try newCoreBpe(
            encoder: encoder,
            specialTokensEncoder: specialTokens,
            pattern: pattern
        )
    }
}

// Extension for convenience methods
public extension CoreBpe {
    /// Encodes text without special tokens
    func encodeText(_ text: String) -> [UInt32] {
        return encode(text: text, allowedSpecial: [])
    }
    
    /// Decodes tokens to string
    func decodeTokens(_ tokens: [UInt32]) -> String? {
        guard let bytes = try? decodeBytes(tokens: tokens) else {
            return nil
        }
        return String(data: bytes, encoding: .utf8)
    }
}
