//
//  ContentView.swift
//  TiktokenSwiftExample
//
//  Created by Nicholas Arner on 8/1/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TiktokenViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Encoding Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Encoding")
                            .font(.headline)
                        
                        Picker("Encoding", selection: $viewModel.selectedEncoding) {
                            ForEach(EncodingType.allCases, id: \.self) { encoding in
                                Text(encoding.displayName)
                                    .tag(encoding)
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(viewModel.isLoading)
                        .onChange(of: viewModel.selectedEncoding) { oldValue, newValue in
                            viewModel.changeEncoding(to: newValue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Input Section
                    InputSection(
                        inputText: $viewModel.inputText,
                        onEncode: {
                            Task {
                                await viewModel.encodeText()
                            }
                        },
                        isLoading: viewModel.isLoading
                    )
                    
                    // Tokens Section
                    if !viewModel.tokens.isEmpty {
                        TokensSection(
                            tokens: viewModel.tokens,
                            onDecode: {
                                Task {
                                    await viewModel.decodeTokens()
                                }
                            },
                            onClear: viewModel.clearTokens,
                            isLoading: viewModel.isLoading
                        )
                    }
                    
                    // Decoded Text Section
                    if !viewModel.decodedText.isEmpty {
                        DecodedTextSection(decodedText: viewModel.decodedText)
                    }
                    
                    // Encoder Info Section
                    if viewModel.vocabularySize > 0 {
                        InfoSection(
                            encodingName: viewModel.selectedEncoding.displayName,
                            vocabularySize: viewModel.vocabularySize,
                            specialTokensCount: viewModel.specialTokensCount,
                            modelList: viewModel.selectedEncoding.modelList
                        )
                    }
                    
                    // Error Message
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("Tiktoken Swift Demo")
            .navigationBarTitleDisplayMode(.large)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

#Preview {
    ContentView()
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}