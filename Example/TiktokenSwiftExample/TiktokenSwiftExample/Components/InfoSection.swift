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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Encoder Information")
                .font(.headline)
            
            HStack {
                Label("Encoding: \(encodingName)", systemImage: "doc.text")
                Spacer()
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