import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
    let isUnlocked: (AppStoreSnapshot) -> Bool

    static func all(store: AppStore) -> [AchievementDefinition] {
        return [
            AchievementDefinition(
                id: "first_stroke",
                title: "First Stroke",
                detail: "Create your first custom brush",
                systemImage: "paintbrush.pointed.fill",
                isUnlocked: { $0.itemsCreated >= 1 }
            ),
            AchievementDefinition(
                id: "brush_enthusiast",
                title: "Brush Enthusiast",
                detail: "Save 10 brushes to your library",
                systemImage: "paintpalette.fill",
                isUnlocked: { $0.itemsCreated >= 10 }
            ),
            AchievementDefinition(
                id: "creative_collection",
                title: "Creative Collection",
                detail: "Build a library of 25 brushes",
                systemImage: "square.grid.3x3.fill",
                isUnlocked: { $0.itemsCreated >= 25 }
            ),
            AchievementDefinition(
                id: "power_user",
                title: "Power User",
                detail: "Save 50 brushes total",
                systemImage: "bolt.fill",
                isUnlocked: { $0.itemsCreated >= 50 }
            ),
            AchievementDefinition(
                id: "active_user",
                title: "Active User",
                detail: "Complete 10 studio sessions",
                systemImage: "figure.walk",
                isUnlocked: { $0.sessionCount >= 10 }
            ),
            AchievementDefinition(
                id: "dedicated_user",
                title: "Dedicated User",
                detail: "Complete 50 studio sessions",
                systemImage: "star.fill",
                isUnlocked: { $0.sessionCount >= 50 }
            ),
            AchievementDefinition(
                id: "three_day_streak",
                title: "Three-Day Streak",
                detail: "Create on 3 days in a row",
                systemImage: "flame.fill",
                isUnlocked: { $0.streak >= 3 }
            ),
            AchievementDefinition(
                id: "week_long_habit",
                title: "Week-Long Habit",
                detail: "Maintain a 7-day streak",
                systemImage: "calendar",
                isUnlocked: { $0.streak >= 7 }
            )
        ]
    }
}

struct AppStoreSnapshot {
    let itemsCreated: Int
    let sessionCount: Int
    let streak: Int
}
