import Foundation

/// Utilities for loading tiktoken encodings
public struct EncodingLoader {
    
    /// Errors that can occur during encoding loading
    public enum LoadError: Error {
        case fileNotFound(String)
        case invalidFormat
        case decodingError(Error)
    }
    
    /// Encoding data structure matching Python's format
    public struct EncodingData: Codable {
        let name: String
        let explicitNVocab: UInt32
        let maxTokenValue: UInt32
        let specialTokens: [String: UInt32]
        let testVocabulary: [String: UInt32]?
        let pattern: String
        
        enum CodingKeys: String, CodingKey {
            case name
            case explicitNVocab = "explicit_n_vocab"
            case maxTokenValue = "max_token_value"
            case specialTokens = "special_tokens"
            case testVocabulary = "test_vocabulary"
            case pattern
        }
    }
    
    /// Load encoding data from a JSON file
    public static func loadEncoding(from path: String) throws -> CoreBpe {
        let url = URL(fileURLWithPath: path)
        
        guard FileManager.default.fileExists(atPath: path) else {
            throw LoadError.fileNotFound(path)
        }
        
        do {
            let data = try Data(contentsOf: url)
            let encodingData = try JSONDecoder().decode(EncodingData.self, from: data)
            
            // For now, use test vocabulary if available
            // In production, you'd load the full BPE ranks
            let stringEncoder = encodingData.testVocabulary ?? [:]
            
            // Convert string keys to byte arrays
            var encoder: [[UInt8]: UInt32] = [:]
            for (key, value) in stringEncoder {
                encoder[Array(key.utf8)] = value
            }
            
            return try newCoreBpe(
                encoder: encoder,
                specialTokensEncoder: encodingData.specialTokens,
                pattern: encodingData.pattern
            )
            
        } catch let error as DecodingError {
            throw LoadError.decodingError(error)
        } catch {
            throw error
        }
    }
    
    /// Create a cl100k_base encoder from embedded data
    /// Note: In production, this would load the actual cl100k_base data
    public static func createCl100kBase() throws -> CoreBpe {
        // This is a placeholder - in reality, you'd embed the actual
        // cl100k_base data or load it from a resource
        print("⚠️  Warning: Using test encoder. Load actual cl100k_base data for production use.")
        return try TiktokenHelper.createTestEncoder()
    }
    
    /// Load encoding from embedded resources
    public static func loadEmbeddedEncoding(named name: String) throws -> CoreBpe {
        // In a real implementation, you'd load from bundle resources
        // For example:
        // guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
        //     throw LoadError.fileNotFound(name)
        // }
        
        switch name {
        case "cl100k_base":
            return try createCl100kBase()
        default:
            throw LoadError.fileNotFound("Encoding '\(name)' not found")
        }
    }
}

// Extension to make loading easier
public extension CoreBpe {
    /// Load a named encoding
    static func encoding(named name: String) throws -> CoreBpe {
        return try EncodingLoader.loadEmbeddedEncoding(named: name)
    }
    
    /// Load encoding from a JSON file
    static func encoding(fromFile path: String) throws -> CoreBpe {
        return try EncodingLoader.loadEncoding(from: path)
    }
}