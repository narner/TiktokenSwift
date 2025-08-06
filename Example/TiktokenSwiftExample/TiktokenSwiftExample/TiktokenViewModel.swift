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
    
    var displayName: String {
        switch self {
        case .cl100kBase:
            return "cl100k_base (GPT-3.5/4)"
        case .r50kBase:
            return "r50k_base (GPT-2)"
        case .p50kBase:
            return "p50k_base (Codex)"
        case .o200kBase:
            return "o200k_base (GPT-4o)"
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
        }
    }
    
    func changeEncoding(to newEncoding: EncodingType) {
        selectedEncoding = newEncoding
        Task {
            await setupEncoder()
        }
    }
}
