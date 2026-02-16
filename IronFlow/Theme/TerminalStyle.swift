import SwiftUI

struct TerminalFont: ViewModifier {
    let size: CGFloat
    let weight: Font.Weight

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: .monospaced))
    }
}

extension View {
    func terminalFont(_ size: CGFloat = 16, weight: Font.Weight = .regular) -> some View {
        modifier(TerminalFont(size: size, weight: weight))
    }
}

struct TerminalButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .terminalFont(14, weight: .bold)
            .foregroundColor(configuration.isPressed ? TN.bg : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(configuration.isPressed ? color : Color.clear)
                    )
            )
    }
}

struct TerminalCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(TN.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(TN.comment.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func terminalCard() -> some View {
        modifier(TerminalCardModifier())
    }
}
