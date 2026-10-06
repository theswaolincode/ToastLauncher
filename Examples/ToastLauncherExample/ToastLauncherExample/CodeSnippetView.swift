//
//  CodeSnippetView.swift
//  ToastLauncherExample
//
//  Created by Daniel Ayala on 06/10/2026.
//

import SwiftUI

/// A dark, Xcode-style editor card that shows a short Swift snippet with syntax colors.
struct CodeSnippetView: View {
    let fileName: String
    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                ForEach([Color.red, .yellow, .green], id: \.self) { color in
                    Circle()
                        .fill(color.opacity(0.85))
                        .frame(width: 11, height: 11)
                }
                Text(fileName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .accessibilityHidden(true)

            Divider()
                .overlay(Color.white.opacity(0.08))

            Text(SwiftHighlighter.highlight(code))
                .font(.system(.callout, design: .monospaced))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                // Each snippet fades in when the demo changes.
                .id(code)
                .transition(.opacity)
        }
        .background(Color(red: 0.12, green: 0.12, blue: 0.15),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08))
        )
        .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
        .environment(\.colorScheme, .dark)
    }
}

/// A tiny tokenizer that's just good enough to color the demo snippets like Xcode's default dark theme.
enum SwiftHighlighter {
    private static let keywords: Set<String> = ["var", "let", "func", "for", "in", "nil", "true", "false", "@StateObject", "@State"]

    private static let plain = Color(white: 0.92)
    private static let keyword = Color(red: 0.99, green: 0.37, blue: 0.64)
    private static let string = Color(red: 0.99, green: 0.42, blue: 0.36)
    private static let number = Color(red: 0.82, green: 0.75, blue: 0.41)
    private static let type = Color(red: 0.36, green: 0.85, blue: 1.00)
    private static let member = Color(red: 0.73, green: 0.55, blue: 0.95)
    private static let comment = Color(red: 0.47, green: 0.53, blue: 0.59)

    static func highlight(_ code: String) -> AttributedString {
        var result = AttributedString()
        var index = code.startIndex
        var previous: Character?

        func append(_ text: Substring, _ color: Color) {
            var run = AttributedString(text)
            run.foregroundColor = color
            result += run
        }

        while index < code.endIndex {
            let character = code[index]
            let rest = code[index...]

            if rest.hasPrefix("//") {
                // A comment runs to the end of the line.
                let end = rest.firstIndex(of: "\n") ?? code.endIndex
                append(code[index..<end], comment)
                index = end
            } else if character == "\"" {
                let afterQuote = code.index(after: index)
                let close = code[afterQuote...].firstIndex(of: "\"") ?? code.index(before: code.endIndex)
                let end = code.index(after: close)
                append(code[index..<end], string)
                index = end
            } else if character.isLetter || character == "_" || character == "@" || character == "$" {
                let end = rest.dropFirst().firstIndex { !($0.isLetter || $0.isNumber || $0 == "_") } ?? code.endIndex
                let word = code[index..<end]
                let color: Color
                if keywords.contains(String(word)) {
                    color = keyword
                } else if previous == "." {
                    color = member
                } else if word.first?.isUppercase == true {
                    color = type
                } else if code[end...].first == "(" {
                    color = member
                } else {
                    color = plain
                }
                append(word, color)
                index = end
            } else if character.isNumber {
                let end = rest.firstIndex { !($0.isNumber || $0 == ".") } ?? code.endIndex
                append(code[index..<end], number)
                index = end
            } else {
                append(code[index...index], plain)
                index = code.index(after: index)
            }

            if let last = result.characters.last, !last.isWhitespace {
                previous = last
            }
        }
        return result
    }
}

#Preview {
    CodeSnippetView(fileName: "ContentView.swift", code: """
    .toast(isPresented: $saved, haptic: .success) {
        ToastView(title: "Saved", background: .glass, style: .auto) {
            saved = false // dismiss
        }
    }
    """)
    .padding()
}
