import Foundation

/// Helper utilities for using Tiktoken
public struct TiktokenHelper {
    /// Creates a test encoder with a small vocabulary
    /// - Note: This is for testing only. In production, load real encoding data.
    public static func createTestEncoder() throws -> CoreBpe {
        // Create a more comprehensive test vocabulary with individual characters
        var encoder: [[UInt8]: UInt32] = [:]
        
        // Add basic ASCII characters as individual tokens
        for i in 32...126 {  // printable ASCII
            let char = UInt8(i)
            encoder[[char]] = UInt32(i)
        }
        
        // Add some common multi-byte sequences
        encoder[Array("hello".utf8)] = 200
        encoder[Array("world".utf8)] = 201
        encoder[Array("test".utf8)] = 202
        encoder[Array("swift".utf8)] = 203
        encoder[Array("tiktoken".utf8)] = 204
        encoder[Array(" ".utf8)] = 32  // space
        encoder[Array("!".utf8)] = 33  // exclamation
        
        // Add newline and other control characters
        encoder[Array("\n".utf8)] = 10
        encoder[Array("\r".utf8)] = 13
        encoder[Array("\t".utf8)] = 9
        
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
        return try? decode(tokens: tokens)
    }
}
