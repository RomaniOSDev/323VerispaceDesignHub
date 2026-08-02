import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.studioTheme) private var theme
    @State private var showResetAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Settings")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                statsCard
                themeCard
                feedbackCard

                StudioCard {
                    VStack(spacing: 0) {
                        settingsRow(title: "Rate Us", icon: "star.fill") {
                            requestReview()
                        }
                        divider
                        settingsRow(title: "Privacy Policy", icon: "hand.raised.fill") {
                            openLink(AppLinks.privacy)
                        }
                        divider
                        settingsRow(title: "Terms of Use", icon: "doc.text.fill") {
                            openLink(AppLinks.terms)
                        }
                        divider
                        Button {
                            HapticFeedback.warning()
                            showResetAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundStyle(.red.opacity(0.9))
                                    .frame(width: 28)
                                Text("Reset All Data")
                                    .foregroundStyle(.red.opacity(0.95))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(theme.textSecondary)
                            }
                            .padding(.vertical, 14)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 100)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .scrollDismissesKeyboard(.interactively)
        .alert("Reset All Data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                store.resetAllData()
            }
        } message: {
            Text("This removes all brushes, stats, and achievements progress from this device.")
        }
    }

    private var statsCard: some View {
        StudioCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Stats")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                HStack {
                    statLine("Brushes saved", "\(store.itemsCreated)")
                    Spacer()
                    statLine("Sessions", "\(store.sessionCount)")
                }
                HStack {
                    statLine("Total usage", "\(store.totalUsageEvents)")
                    Spacer()
                    statLine("Streak", "\(store.streak) days")
                }
            }
        }
    }

    private var themeCard: some View {
        StudioCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Studio Theme")
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
                Text("Switch the atmosphere of the whole app.")
                    .font(.caption)
                    .foregroundStyle(theme.textSecondary)

                ForEach(StudioTheme.allCases) { option in
                    Button {
                        store.studioTheme = option
                        HapticFeedback.selection()
                    } label: {
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [option.primary, option.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(option.background.opacity(0.35))
                                }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(theme.textPrimary)
                                Text(option.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(theme.textSecondary)
                            }
                            Spacer()
                            if store.studioTheme == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(theme.accent)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var feedbackCard: some View {
        StudioCard {
            VStack(spacing: 0) {
                Toggle(isOn: $store.soundEnabled) {
                    labelRow(title: "Sound Effects", icon: "speaker.wave.2.fill")
                }
                .tint(theme.accent)
                .padding(.vertical, 8)
                .onChange(of: store.soundEnabled) { enabled in
                    if enabled { HapticFeedback.selection() }
                }

                divider

                Toggle(isOn: $store.hapticsEnabled) {
                    labelRow(title: "Haptic Feedback", icon: "waveform")
                }
                .tint(theme.accent)
                .padding(.vertical, 8)
                .onChange(of: store.hapticsEnabled) { enabled in
                    if enabled { HapticFeedback.selection() }
                }
            }
        }
    }

    private func labelRow(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(theme.accent)
                .frame(width: 28)
            Text(title)
                .foregroundStyle(theme.textPrimary)
        }
    }

    private func statLine(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(theme.accent)
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
        }
    }

    private var divider: some View {
        Divider().overlay(Color.white.opacity(0.08))
    }

    private func settingsRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticFeedback.lightTap()
            action()
        } label: {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(theme.accent)
                    .frame(width: 28)
                Text(title)
                    .foregroundStyle(theme.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.textSecondary)
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func openLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
