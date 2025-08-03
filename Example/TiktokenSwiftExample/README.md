# TiktokenSwift Example App

This is a SwiftUI example application demonstrating the usage of the TiktokenSwift package for tokenization.

## Setup Instructions

### Adding TiktokenSwift Dependency

Since this is an Xcode project, you need to add the TiktokenSwift package dependency:

1. Open `TiktokenSwiftExample.xcodeproj` in Xcode
2. Select the project in the navigator
3. Select the "TiktokenSwiftExample" target
4. Go to "General" tab → "Frameworks, Libraries, and Embedded Content"
5. Click the "+" button
6. Choose "Add Other..." → "Add Package Dependency..."
7. Add the local package by navigating to: `/Users/nicholasarner/Development/Active/tiktoken/TiktokenSwift`
8. Click "Add Package"

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
3. View the generated tokens
4. Click "Decode Tokens" to convert back to text
5. Use "Clear" to reset tokens and decoded text

## Requirements

- iOS 14.0+ / macOS 11.0+
- Xcode 15.0+
- Swift 5.9+