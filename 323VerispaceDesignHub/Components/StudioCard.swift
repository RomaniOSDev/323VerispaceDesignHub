import SwiftUI

struct StudioCard<Content: View>: View {
    @Environment(\.studioTheme) private var theme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                theme.surface.opacity(0.95),
                                theme.surface.opacity(0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
            }
    }
}

struct StatCard: View {
    @Environment(\.studioTheme) private var theme
    let title: String
    let value: String
    let icon: String

    var body: some View {
        StudioCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(theme.accent)
                    Spacer()
                }
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.textPrimary)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(theme.textSecondary)
            }
        }
    }
}
