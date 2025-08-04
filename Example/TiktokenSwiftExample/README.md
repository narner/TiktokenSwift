# TiktokenSwift Example App

A SwiftUI example application demonstrating the usage of TiktokenSwift - Swift bindings for OpenAI's tiktoken library.

<img src="TiktokenSwiftExample.gif" alt="TiktokenSwift Example Demo" width="50%">

## Setup Instructions

### Adding TiktokenSwift Dependency

#### Option 1: Using the Remote Package (Recommended)

1. Open `TiktokenSwiftExample.xcodeproj` in Xcode
2. Go to File → Add Package Dependencies...
3. Enter the package URL: `https://github.com/narner/TiktokenSwift.git`
4. Choose the version rule (e.g., "Up to Next Major" from 0.1.0)
5. Click "Add Package"

#### Option 2: Using Local Package for Development

1. Open `TiktokenSwiftExample.xcodeproj` in Xcode
2. Drag the parent `TiktokenSwift` folder into the Xcode project navigator
3. When prompted, choose "Create folder references"
4. The local package will be automatically linked

## Features

The example app demonstrates:

- **Text Encoding**: Convert text into token arrays
- **Token Visualization**: Display tokens with indices in a scrollable view
- **Token Decoding**: Convert tokens back to text
- **Encoder Information**: Display vocabulary size and special tokens count
- **Error Handling**: User-friendly error messages
- **Loading States**: Visual feedback during operations

## Architecture

The app follows MVVM architecture:

- **TiktokenViewModel**: Manages state and business logic
- **ContentView**: Main coordinator view
- **Component Views**: Modular UI components in the Components folder
  - InputSection: Text input and encode button
  - TokensSection: Token display and decode/clear buttons
  - TokenView: Individual token visualization
  - DecodedTextSection: Decoded text display
  - InfoSection: Encoder information display

## Usage

1. Enter text in the input field
2. Click "Encode Text" to convert to tokens
3. View the generated tokens with their indices
4. Click "Decode Tokens" to convert back to text
5. Use "Clear" to reset tokens and decoded text

## Example Code

The app demonstrates basic TiktokenSwift usage:

```swift
import TiktokenSwift

// Initialize the encoder
let encoder = try await CoreBpe.cl100kBase()

// Encode text to tokens
let text = "Hello, world!"
let tokens = encoder.encodeText(text)

// Decode tokens back to text
if let decoded = encoder.decodeTokens(tokens) {
    print("Decoded: \(decoded)")
}
```

## Requirements

- iOS 13.0+ / macOS 10.15+
- Xcode 14.0+
- Swift 5.9+