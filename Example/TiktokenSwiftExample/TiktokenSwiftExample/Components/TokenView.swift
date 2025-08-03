//
//  TokenView.swift
//  TiktokenSwiftExample
//
//  Created by Assistant on 1/1/25.
//

import SwiftUI

struct TokenView: View {
    let token: UInt32
    let index: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(index)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text("\(token)")
                .font(.system(.callout, design: .monospaced))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
        }
    }
}

#Preview {
    HStack {
        TokenView(token: 9906, index: 0)
        TokenView(token: 11, index: 1)
        TokenView(token: 1917, index: 2)
        TokenView(token: 0, index: 3)
    }
    .padding()
}