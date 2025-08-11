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
    @State private var showSamples = false
    
    let sampleTexts = [
        "Hello, GPT-5! This is a test of the new o200k_base encoding.",
        "Testing GPT-4.5 and GPT-4.1 models with improved performance.",
        "The new o3 and o4-mini models are optimized for reasoning tasks.",
        "Using o200k_harmony encoding for structured output with <|constrain|> and <|return|> tokens.",
        "Compare token efficiency: GPT-5 vs GPT-4 vs GPT-3.5-turbo"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Input Text")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    ForEach(sampleTexts, id: \.self) { sample in
                        Button(action: {
                            inputText = sample
                        }) {
                            Text(sample)
                                .lineLimit(1)
                        }
                    }
                } label: {
                    Label("Samples", systemImage: "text.quote")
                        .font(.caption)
                }
                .menuStyle(.borderlessButton)
                
                if !inputText.isEmpty {
                    Button(action: {
                        inputText = ""
                    }) {
                        Label("Clear", systemImage: "xmark.circle.fill")
                            .labelStyle(.iconOnly)
                            .foregroundColor(.gray)
                            .imageScale(.medium)
                    }
                }
            }
            
            TextEditor(text: $inputText)
                .frame(minHeight: 100)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                onEncode()
            }) {
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