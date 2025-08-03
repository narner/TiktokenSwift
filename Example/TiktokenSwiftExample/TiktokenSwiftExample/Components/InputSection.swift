//
//  InputSection.swift
//  TiktokenSwiftExample
//
//  Created by Assistant on 1/1/25.
//

import SwiftUI

struct InputSection: View {
    @Binding var inputText: String
    let onEncode: () -> Void
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Input Text")
                .font(.headline)
            
            TextEditor(text: $inputText)
                .frame(minHeight: 100)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            Button(action: onEncode) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.down.doc")
                    }
                    Text("Encode Text")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.isEmpty || isLoading)
        }
    }
}

#Preview {
    InputSection(
        inputText: .constant("Hello, world!"),
        onEncode: {},
        isLoading: false
    )
    .padding()
}