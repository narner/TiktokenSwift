//
//  TokensSection.swift
//  TiktokenSwiftExample
//
//  Created by Assistant on 1/1/25.
//

import SwiftUI

struct TokensSection: View {
    let tokens: [UInt32]
    let onDecode: () -> Void
    let onClear: () -> Void
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tokens")
                    .font(.headline)
                Spacer()
                Text("Count: \(tokens.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 8) {
                    ForEach(Array(tokens.enumerated()), id: \.offset) { index, token in
                        TokenView(token: token, index: index)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(height: 80)
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            HStack(spacing: 12) {
                Button(action: onDecode) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.up.doc")
                        }
                        Text("Decode Tokens")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
                
                Button(action: onClear) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)
            }
        }
    }
}

#Preview {
    TokensSection(
        tokens: [9906, 11, 1917, 0],
        onDecode: {},
        onClear: {},
        isLoading: false
    )
    .padding()
}