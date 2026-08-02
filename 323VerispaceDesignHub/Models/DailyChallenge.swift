import Foundation

enum ChallengeKind: String, Codable {
    case createBrush
    case useFavorite
    case tryPreset
    case practiceStroke
    case tagBrush
    case compareBrushes
}

struct DailyChallenge: Identifiable, Equatable {
    let id: String
    let title: String
    let detail: String
    let kind: ChallengeKind
    let target: Int

    static func challenge(for dayKey: String) -> DailyChallenge {
        let catalog: [DailyChallenge] = [
            DailyChallenge(
                id: "create",
                title: "Forge a Brush",
                detail: "Save 1 new brush from the designer today.",
                kind: .createBrush,
                target: 1
            ),
            DailyChallenge(
                id: "favorite_use",
                title: "Reach for a Favorite",
                detail: "Record usage on a favorited brush.",
                kind: .useFavorite,
                target: 1
            ),
            DailyChallenge(
                id: "preset",
                title: "Try a Preset",
                detail: "Apply any studio preset, then save a brush.",
                kind: .tryPreset,
                target: 1
            ),
            DailyChallenge(
                id: "practice",
                title: "Warm-up Strokes",
                detail: "Draw at least 3 strokes on the practice canvas.",
                kind: .practiceStroke,
                target: 3
            ),
            DailyChallenge(
                id: "tag",
                title: "Label Your Tools",
                detail: "Assign a non-custom tag to a brush.",
                kind: .tagBrush,
                target: 1
            ),
            DailyChallenge(
                id: "compare",
                title: "Side by Side",
                detail: "Open the compare view with two brushes.",
                kind: .compareBrushes,
                target: 1
            )
        ]
        let hash = abs(dayKey.utf8.reduce(0) { ($0 &* 31) &+ Int($1) })
        return catalog[hash % catalog.count]
    }
}

struct WeeklyRecap {
    let brushesCreated: Int
    let usageEvents: Int
    let topBrushName: String?
    let favoriteCount: Int
    let activeDays: Int
    let streak: Int
}
