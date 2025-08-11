//
//  TiktokenViewModel.swift
//  TiktokenSwiftExample
//
//  Created by Assistant on 1/1/25.
//

import SwiftUI
import TiktokenSwift

enum EncodingType: String, CaseIterable {
    case cl100kBase = "cl100k_base"
    case r50kBase = "r50k_base" 
    case p50kBase = "p50k_base"
    case o200kBase = "o200k_base"
    case o200kHarmony = "o200k_harmony"
    
    var displayName: String {
        switch self {
        case .cl100kBase:
            return "cl100k_base (GPT-3.5/4)"
        case .r50kBase:
            return "r50k_base (GPT-2)"
        case .p50kBase:
            return "p50k_base (Codex)"
        case .o200kBase:
            return "o200k_base (GPT-5/4.5/4.1/o3/o4-mini/GPT-4o)"
        case .o200kHarmony:
            return "o200k_harmony (gpt-oss)"
        }
    }
    
    var modelList: String {
        switch self {
        case .cl100kBase:
            return "GPT-4, GPT-3.5-turbo"
        case .r50kBase:
            return "GPT-2, legacy models"
        case .p50kBase:
            return "Codex models"
        case .o200kBase:
            return "GPT-5, GPT-4.5, GPT-4.1, o1, o3, o4-mini, GPT-4o"
        case .o200kHarmony:
            return "gpt-oss (structured output)"
        }
    }
}

@MainActor
class TiktokenViewModel: ObservableObject {
    @Published var inputText = "Hello, world! This is a test of the tiktoken Swift bindings."
    @Published var tokens: [UInt32] = []
    @Published var decodedText = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var selectedEncoding: EncodingType = .o200kBase
    
    private var encoder: CoreBpe?
    
    init() {
        Task {
            await setupEncoder()
        }
    }
    
    func setupEncoder() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Load the selected encoder (downloads on first use, then caches)
            switch selectedEncoding {
            case .cl100kBase:
                encoder = try await CoreBpe.cl100kBase()
            case .r50kBase:
                encoder = try await CoreBpe.r50kBase()
            case .p50kBase:
                encoder = try await CoreBpe.p50kBase()
            case .o200kBase:
                encoder = try await CoreBpe.o200kBase()
            case .o200kHarmony:
                encoder = try await CoreBpe.o200kHarmony()
            }
            errorMessage = ""
            
            // Clear tokens when switching encoders
            tokens = []
            decodedText = ""
        } catch {
            errorMessage = "Failed to load \(selectedEncoding.rawValue) encoder: \(error.localizedDescription)"
            
            // Fall back to test encoder if download fails
            do {
                encoder = try TiktokenHelper.createTestEncoder()
                errorMessage = "Using test encoder (download failed)"
            } catch {
                errorMessage = "Failed to create encoder: \(error.localizedDescription)"
            }
        }
    }
    
    func encodeText() async {
        guard let encoder = encoder else {
            errorMessage = "Encoder not initialized"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        errorMessage = ""
        
        // Perform encoding on background thread
        let text = inputText
        let result = await Task.detached { [encoder] in
            return encoder.encode(text: text, allowedSpecial: [])
        }.value
        tokens = result
    }
    
    func decodeTokens() async {
        guard let encoder = encoder else {
            errorMessage = "Encoder not initialized"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        errorMessage = ""
        
        // Perform decoding on background thread
        let tokensToProcess = tokens
        do {
            let result = try await Task.detached { [encoder] in
                return try encoder.decode(tokens: tokensToProcess)
            }.value
            
            // The new decode method returns String? directly
            if let decoded = result {
                decodedText = decoded
            } else {
                errorMessage = "Failed to decode tokens to valid UTF-8 string"
            }
        } catch {
            errorMessage = "Failed to decode tokens: \(error.localizedDescription)"
        }
    }
    
    func clearTokens() {
        tokens = []
        decodedText = ""
        errorMessage = ""
    }
    
    var vocabularySize: Int {
        // This information is not available in the simplified interface
        // Return estimated sizes based on encoding type
        switch selectedEncoding {
        case .cl100kBase:
            return 100256
        case .r50kBase:
            return 50257
        case .p50kBase:
            return 50281
        case .o200kBase:
            return 200000
        case .o200kHarmony:
            return 200018  // o200k_base + additional special tokens
        }
    }
    
    var specialTokensCount: Int {
        // Special tokens count based on encoding type
        switch selectedEncoding {
        case .cl100kBase:
            return 5
        case .r50kBase:
            return 1
        case .p50kBase:
            return 1
        case .o200kBase:
            return 2
        case .o200kHarmony:
            return 20  // Many special tokens for structured output
        }
    }
    
    func changeEncoding(to newEncoding: EncodingType) {
        selectedEncoding = newEncoding
        Task {
            await setupEncoder()
        }
    }
}
