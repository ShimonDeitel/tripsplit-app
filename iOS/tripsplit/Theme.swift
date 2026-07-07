import SwiftUI

/// ledger-green with a receipt-mint accent
enum Theme {
    static let background = Color(red: 0.067, green: 0.102, blue: 0.078)
    static let accent = Color(red: 0.298, green: 0.686, blue: 0.431)
    static let ink = Color(red: 0.925, green: 0.965, blue: 0.937)
    static let cardBackground = Color(red: 0.137, green: 0.173, blue: 0.149)
    static let secondaryInk = Color(red: 0.769, green: 0.808, blue: 0.78)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 18
}

extension View {
    func themedBackground() -> some View {
        self.background(Theme.background.ignoresSafeArea())
    }
}
