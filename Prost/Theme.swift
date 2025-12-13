import SwiftUI

/// Minimal design system for the Reading module. We'll evolve this as the app grows.
enum ProstTheme {
    enum Colors {
        // Much lighter, readable background
        static let backgroundTop = Color(red: 0.96, green: 0.97, blue: 0.98)
        static let backgroundBottom = Color(red: 0.92, green: 0.94, blue: 0.96)

        // Bright white cards with clear borders
        static let card = Color.white
        static let cardBorder = Color.black.opacity(0.08)
        static let chip = Color(white: 0.95)
        static let chipBorder = Color.black.opacity(0.06)

        // Accents
        static let accentSoft = Color.accentColor.opacity(0.12)
        static let accentBorder = Color.accentColor.opacity(0.3)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let success = Color.green
        static let danger = Color.red
    }

    enum Radius {
        static let card: CGFloat = 18
        static let pill: CGFloat = 999
    }

    enum Spacing {
        static let screenPadding: CGFloat = 20
        static let section: CGFloat = 20
        static let item: CGFloat = 12
    }

    enum Typography {
        static let hero = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title = Font.system(.headline, design: .rounded).weight(.semibold)
        static let body = Font.system(.body, design: .rounded)
        static let caption = Font.system(.footnote, design: .rounded)
    }

    enum Shadow {
        static let cardRadius: CGFloat = 12
        static let cardY: CGFloat = 4
        static let cardOpacity: CGFloat = 0.08
    }
}

struct ProstBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    colors: [ProstTheme.Colors.backgroundTop, ProstTheme.Colors.backgroundBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
    }
}

extension View {
    func prostBackground() -> some View { modifier(ProstBackground()) }
}


