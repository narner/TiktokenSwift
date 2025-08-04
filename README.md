# TiktokenSwift

Swift bindings for OpenAI's tiktoken library - a fast BPE tokenizer for use with OpenAI's models.

## Features

- 🚀 Fast tokenization using Rust implementation
- 📱 Support for iOS and macOS
- 🔧 Simple Swift API
- 🎯 Compatible with OpenAI's token formats
- 📦 Easy integration via Swift Package Manager

## Installation

### Swift Package Manager

Add TiktokenSwift to your project:

```swift
dependencies: [
    .package(url: "https://github.com/narner/TiktokenSwift.git", from: "0.1.0")
]
```

## Quick Start

```swift
import TiktokenSwift

// Load OpenAI's cl100k_base encoding
let encoder = try await CoreBpe.cl100kBase()

// Encode text
let text = "Hello, world!"
let tokens = encoder.encodeText(text)
print("Tokens: \(tokens)")

// Decode tokens
if let decoded = encoder.decodeTokens(tokens) {
    print("Decoded: \(decoded)")
}
```

## Available Encodings

```swift
// cl100k_base - Used by GPT-3.5-turbo and GPT-4
let cl100k = try await CoreBpe.cl100kBase()

// Other encodings
let r50k = try await CoreBpe.r50kBase()    // Older models
let p50k = try await CoreBpe.p50kBase()    // Codex models
let o200k = try await CoreBpe.o200kBase()   // Newer encoding
```

## Advanced Usage

### Encoding with Special Tokens

```swift
let textWithSpecial = "Hello <|endoftext|> World"
let tokensWithSpecial = encoder.encode(
    text: textWithSpecial, 
    allowedSpecial: ["<|endoftext|>"]
)

// Or encode with all special tokens
let tokensWithAllSpecial = encoder.encodeWithSpecialTokens(text: textWithSpecial)
```

### Encoding with Details

```swift
let details = encoder.encodeWithDetails(
    text: "Hello world",
    allowedSpecial: []
)
print("Tokens: \(details.tokens)")
print("Last token length: \(details.lastPieceTokenLen)")
```

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Xcode 14.0+
- Swift 5.9+

## Architecture Support

- iOS: arm64
- iOS Simulator: arm64, x86_64
- macOS: arm64, x86_64

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Acknowledgments

This project provides Swift bindings for [tiktoken](https://github.com/openai/tiktoken), originally developed by OpenAI.