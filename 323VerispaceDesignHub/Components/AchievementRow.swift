import SwiftUI

struct AchievementRow: View {
    let title: String
    let detail: String
    let systemImage: String
    let unlocked: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        unlocked
                            ? LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                            : LinearGradient(
                                colors: [Color("AppSurface"), Color("AppBackground")],
                                startPoint: .top,
                                endPoint: .bottom
                              )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: unlocked ? Color("AppPrimary").opacity(0.4) : .clear, radius: 8, y: 4)
                Image(systemName: systemImage)
                    .foregroundStyle(unlocked ? Color("AppBackground") : Color("AppTextSecondary"))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Image(systemName: unlocked ? "checkmark.seal.fill" : "lock.fill")
                .foregroundStyle(unlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.6))
        }
        .padding(.vertical, 4)
    }
}
