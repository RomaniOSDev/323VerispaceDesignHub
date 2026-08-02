import SwiftUI

struct FloatingTab: Identifiable, Equatable {
    let id: Int
    let title: String
    let systemImage: String
}

struct FloatingTabBar: View {
    @Environment(\.studioTheme) private var theme
    @Binding var selection: Int
    let tabs: [FloatingTab]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(tabs) { tab in
                Button {
                    HapticFeedback.selection()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        selection = tab.id
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 15, weight: .semibold))
                        if selection == tab.id {
                            Text(tab.title)
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .foregroundStyle(selection == tab.id ? theme.background : theme.textSecondary)
                    .padding(.horizontal, selection == tab.id ? 14 : 12)
                    .padding(.vertical, 12)
                    .background {
                        if selection == tab.id {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [theme.primary, theme.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: theme.primary.opacity(0.45), radius: 8, y: 4)
                        } else {
                            Capsule()
                                .fill(theme.surface.opacity(0.35))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background {
            Capsule()
                .fill(theme.surface.opacity(0.92))
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}
