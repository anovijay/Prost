import SwiftUI

// Minimal card modifier for clean content containers
struct ProstCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: ProstTheme.Radius.card, style: .continuous)
                    .fill(ProstTheme.Colors.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: ProstTheme.Radius.card, style: .continuous)
                            .stroke(ProstTheme.Colors.cardBorder, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(ProstTheme.Shadow.cardOpacity), radius: ProstTheme.Shadow.cardRadius, x: 0, y: ProstTheme.Shadow.cardY)
            )
    }
}

extension View {
    func prostCard() -> some View { modifier(ProstCard()) }
}


