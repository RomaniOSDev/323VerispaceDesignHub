import SwiftUI

struct PrimaryButton: View {
    @Environment(\.studioTheme) private var theme
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.lightTap()
            action()
        }) {
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.background)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [theme.primary, theme.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: theme.primary.opacity(0.45), radius: 10, y: 5)
                }
        }
        .buttonStyle(.plain)
    }
}
