import Foundation

/// Loader for cl100k_base encoding data
public struct Cl100kBaseLoader {
    
    /// Encoding data format for cl100k_base
    public struct EncodingData: Codable {
        let name: String
        let vocabSize: UInt32
        let maxTokenValue: UInt32
        let pattern: String
        let specialTokens: [String: UInt32]
        let tokenBytes: [String?]  // Base64 encoded bytes, indexed by token ID
        let format: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case vocabSize = "vocab_size"
            case maxTokenValue = "max_token_value"
            case pattern
            case specialTokens = "special_tokens"
            case tokenBytes = "token_bytes"
            case format
        }
    }
    
    /// Load cl100k_base encoding from a JSON file
    public static func loadFromFile(_ path: String) throws -> CoreBpe {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)
        let encodingData = try JSONDecoder().decode(EncodingData.self, from: data)
        
        return try createEncoder(from: encodingData)
    }
    
    /// Load cl100k_base encoding from embedded data
    public static func loadFromData(_ data: Data) throws -> CoreBpe {
        let encodingData = try JSONDecoder().decode(EncodingData.self, from: data)
        return try createEncoder(from: encodingData)
    }
    
    /// Create encoder from encoding data
    private static func createEncoder(from encodingData: EncodingData) throws -> CoreBpe {
        print("📂 Loading \(encodingData.name) encoding...")
        print("   Vocabulary size: \(encodingData.vocabSize)")
        print("   Token bytes: \(encodingData.tokenBytes.compactMap { $0 }.count)")
        
        // Build the encoder dictionary from token bytes
        var encoder: [[UInt8]: UInt32] = [:]
        
        // Process each token
        for (tokenId, base64Bytes) in encodingData.tokenBytes.enumerated() {
            guard let base64Bytes = base64Bytes,
                  let tokenData = Data(base64Encoded: base64Bytes) else {
                continue
            }
            
            // Store as byte array directly
            encoder[Array(tokenData)] = UInt32(tokenId)
        }
        
        print("   Built encoder with \(encoder.count) entries")
        
        // Create the CoreBpe instance
        return try newCoreBpe(
            encoder: encoder,
            specialTokensEncoder: encodingData.specialTokens,
            pattern: encodingData.pattern
        )
    }
    
    /// Create a proper BPE encoder that matches tiktoken's behavior
    /// Note: This is a simplified version. Full BPE implementation would need:
    /// 1. Proper byte-level BPE tokenization
    /// 2. Merge rules application
    /// 3. Exact pattern matching as tiktoken
    public static func createCl100kBaseEncoder(from data: EncodingData) throws -> CoreBpe {
        // This would need a more sophisticated implementation to exactly match tiktoken
        // For now, we'll use the simple token-to-string mapping
        return try createEncoder(from: data)
    }
}

// Convenience extension
public extension CoreBpe {
    /// Load cl100k_base encoding from a file
    static func cl100kBase(fromFile path: String) throws -> CoreBpe {
        return try Cl100kBaseLoader.loadFromFile(path)
    }
}