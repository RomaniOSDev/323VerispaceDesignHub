import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Achievements")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Unlock milestones as you design and organize brushes.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))

                StudioCard {
                    VStack(spacing: 16) {
                        ForEach(AchievementDefinition.all(store: store)) { achievement in
                            AchievementRow(
                                title: achievement.title,
                                detail: achievement.detail,
                                systemImage: achievement.systemImage,
                                unlocked: achievement.isUnlocked(store.snapshot)
                            )
                            if achievement.id != "week_long_habit" {
                                Divider().overlay(Color.white.opacity(0.08))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 100)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
