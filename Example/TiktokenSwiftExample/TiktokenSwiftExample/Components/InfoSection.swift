//
//  InfoSection.swift
//  TiktokenSwiftExample
//
//  Created by Assistant on 1/1/25.
//

import SwiftUI

struct InfoSection: View {
    let encodingName: String
    let vocabularySize: Int
    let specialTokensCount: Int
    let modelList: String?
    
    init(encodingName: String, vocabularySize: Int, specialTokensCount: Int, modelList: String? = nil) {
        self.encodingName = encodingName
        self.vocabularySize = vocabularySize
        self.specialTokensCount = specialTokensCount
        self.modelList = modelList
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Encoder Information")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Encoding: \(encodingName)", systemImage: "doc.text")
                    Spacer()
                }
                
                if let modelList = modelList {
                    HStack(alignment: .top) {
                        Image(systemName: "cpu")
                            .foregroundColor(.blue)
                        Text("Models: \(modelList)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                HStack {
                    Label("Vocabulary Size: \(vocabularySize.formatted())", systemImage: "book")
                    Spacer()
                }
                
                HStack {
                    Label("Special Tokens: \(specialTokensCount)", systemImage: "star")
                    Spacer()
                }
            }
            
            if encodingName.contains("GPT-5") || encodingName.contains("o200k") {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.orange)
                    Text("Latest model support from tiktoken v0.11.0")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
                .padding(.top, 4)
            }
        }
        .font(.caption)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    InfoSection(encodingName: "cl100k_base (GPT-3.5/4)", vocabularySize: 100256, specialTokensCount: 5)
        .padding()
}