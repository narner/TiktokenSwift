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

// Decode tokens (returns String? directly)
if let decoded = try encoder.decode(tokens: tokens) {
    print("Decoded: \(decoded)")
}
```

## Available Encodings

```swift
// cl100k_base - Used by GPT-3.5-turbo and GPT-4
let cl100k = try await CoreBpe.cl100kBase()

// o200k_base - Used by GPT-4o and newer models
let o200k = try await CoreBpe.o200kBase()

// Other encodings
let r50k = try await CoreBpe.r50kBase()    // GPT-2 and older models
let p50k = try await CoreBpe.p50kBase()    // Codex models

// Load by name
let encoder = try await CoreBpe.loadEncoding(named: "cl100k_base")
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

### Model Token Limits

Common token limits for OpenAI models:
- GPT-4: 8,192 tokens (standard), 32,768 tokens (32k), 128,000 tokens (turbo)
- GPT-3.5-turbo: 4,096 tokens (standard), 16,385 tokens (16k)
- GPT-4o: 128,000 tokens

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

## Performance

TiktokenSwift uses the same Rust-based core as the official Python tiktoken library, providing:
- Fast BPE tokenization optimized in Rust
- Thread-safe encoding/decoding operations
- Efficient memory usage with lazy vocabulary loading

## Troubleshooting

### Vocabulary Download Issues
The first time you use an encoding, it will download the vocabulary file (~1-2MB) from OpenAI's servers. These are cached in `~/Library/Caches/tiktoken/` for subsequent use.

If you encounter download issues:
1. Check your internet connection
2. Verify the cache directory has write permissions
3. Try clearing the cache and re-downloading

## Acknowledgments

This project provides Swift bindings for [tiktoken](https://github.com/openai/tiktoken), originally developed by OpenAI.