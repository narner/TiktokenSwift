//
//  DecodedTextSection.swift
//  TiktokenSwiftExample
//
//  Created by Assistant on 1/1/25.
//

import SwiftUI

struct DecodedTextSection: View {
    let decodedText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Decoded Text")
                .font(.headline)
            
            Text(decodedText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .textSelection(.enabled)
        }
    }
}

#Preview {
    DecodedTextSection(decodedText: "Hello, world!")
        .padding()
}