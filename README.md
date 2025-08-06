# TiktokenSwift

Native Swift wrapper for OpenAI's [tiktoken](https://github.com/openai/tiktoken) library, providing fast BPE tokenization for OpenAI models.

TiktokenSwift brings the official tiktoken tokenizer to Swift applications through a lightweight FFI bridge, maintaining the same performance and accuracy as the original Python implementation. It supports all standard OpenAI encodings including `cl100k_base` (used by GPT-3.5-turbo and GPT-4), `r50k_base`, `p50k_base`, and `o200k_base`.

📱 Check out the [example SwiftUI app](Example/TiktokenSwiftExample) to see TiktokenSwift in action!

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
let tokens = encoder.encode(text: text, allowedSpecial: [])
print("Tokens: \(tokens)")

// Decode tokens
let decodedBytes = try encoder.decodeBytes(tokens: tokens)
if let decoded = String(data: Data(decodedBytes), encoding: .utf8) {
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

// Or encode ordinary text (without special tokens)
let tokensOrdinary = encoder.encodeOrdinary(text: "Hello <|endoftext|> World")
```

### Working with Token Counts

```swift
// Get token count for text
let text = "The quick brown fox jumps over the lazy dog"
let tokens = encoder.encode(text: text, allowedSpecial: [])
print("Token count: \(tokens.count)")

// Useful for API rate limiting
let maxTokens = 4096
if tokens.count > maxTokens {
    print("Text exceeds token limit")
}
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