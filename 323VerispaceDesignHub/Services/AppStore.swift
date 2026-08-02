import Combine
import Foundation
import SwiftUI

final class AppStore: ObservableObject {
    enum PreferenceKeys {
        static let soundEnabled = "app.soundEnabled"
        static let hapticsEnabled = "app.hapticsEnabled"
        static let theme = "app.studioTheme"
    }

    @Published private(set) var brushes: [BrushItem] = []
    @Published private(set) var hasCompletedOnboarding: Bool = false
    @Published private(set) var itemsCreated: Int = 0
    @Published private(set) var sessionCount: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var totalUsageEvents: Int = 0
    @Published private(set) var dailyUsage: [String: Int] = [:]
    @Published private(set) var challengeProgress: Int = 0
    @Published private(set) var challengeCompletedDay: String?
    @Published private(set) var usedPresetToday: Bool = false

    @Published var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: PreferenceKeys.soundEnabled) }
    }

    @Published var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: PreferenceKeys.hapticsEnabled) }
    }

    @Published var studioTheme: StudioTheme {
        didSet { defaults.set(studioTheme.rawValue, forKey: PreferenceKeys.theme) }
    }

    @Published var designerSize: Double = 24
    @Published var designerOpacity: Double = 0.85
    @Published var designerTexture: Double = 0.5
    @Published var designerName: String = ""
    @Published var designerTag: BrushTag = .custom
    @Published var designerColorHex: String = "59BB75"

    @Published private(set) var undoStack: [DesignerSnapshot] = []
    @Published private(set) var redoStack: [DesignerSnapshot] = []

    private let defaults: UserDefaults
    private var lastActivityDayKey: String?
    private var lastSessionRecordedDay: String?
    private var practiceStrokeCountToday: Int = 0
    private var suppressHistory = false

    private enum Keys {
        static let brushes = "app.brushes"
        static let onboarding = "app.onboardingDone"
        static let itemsCreated = "app.itemsCreated"
        static let sessionCount = "app.sessionCount"
        static let streak = "app.streak"
        static let totalUsage = "app.totalUsage"
        static let lastActivity = "app.lastActivityDay"
        static let previousActivity = "app.previousActivityDay"
        static let dailyUsage = "app.dailyUsage"
        static let challengeProgress = "app.challengeProgress"
        static let challengeDay = "app.challengeDay"
        static let challengeCompleted = "app.challengeCompletedDay"
        static let usedPreset = "app.usedPresetDay"
        static let practiceStrokes = "app.practiceStrokesDay"
        static let practiceCount = "app.practiceStrokeCount"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: PreferenceKeys.soundEnabled) == nil {
            self.soundEnabled = true
        } else {
            self.soundEnabled = defaults.bool(forKey: PreferenceKeys.soundEnabled)
        }
        if defaults.object(forKey: PreferenceKeys.hapticsEnabled) == nil {
            self.hapticsEnabled = true
        } else {
            self.hapticsEnabled = defaults.bool(forKey: PreferenceKeys.hapticsEnabled)
        }
        if let raw = defaults.string(forKey: PreferenceKeys.theme),
           let theme = StudioTheme(rawValue: raw) {
            self.studioTheme = theme
        } else {
            self.studioTheme = .midnight
        }
        load()
        refreshChallengeDay()
        recordSessionIfNeeded()
    }

    var snapshot: AppStoreSnapshot {
        AppStoreSnapshot(itemsCreated: itemsCreated, sessionCount: sessionCount, streak: streak)
    }

    var designerSnapshot: DesignerSnapshot {
        DesignerSnapshot(
            size: designerSize,
            opacity: designerOpacity,
            texture: designerTexture,
            name: designerName,
            tag: designerTag,
            colorHex: designerColorHex
        )
    }

    var designerStrokeColor: Color {
        Color(hex: designerColorHex) ?? studioTheme.accent
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    var todayChallenge: DailyChallenge {
        DailyChallenge.challenge(for: Self.dayKey(from: Date()))
    }

    var isChallengeComplete: Bool {
        challengeCompletedDay == Self.dayKey(from: Date())
    }

    var usageByBrush: [(brush: BrushItem, count: Int)] {
        brushes
            .map { ($0, $0.usageCount) }
            .sorted { $0.count > $1.count }
    }

    var activityLast14Days: [(day: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<14).reversed().compactMap { offset -> (Date, Int)? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let key = Self.dayKey(from: day)
            return (day, dailyUsage[key, default: 0])
        }
    }

    var averageBrushSize: Double {
        guard !brushes.isEmpty else { return 0 }
        return brushes.map(\.size).reduce(0, +) / Double(brushes.count)
    }

    var averageBrushOpacity: Double {
        guard !brushes.isEmpty else { return 0 }
        return brushes.map(\.opacity).reduce(0, +) / Double(brushes.count)
    }

    var averageBrushTexture: Double {
        guard !brushes.isEmpty else { return 0 }
        return brushes.map(\.texture).reduce(0, +) / Double(brushes.count)
    }

    var parameterBuckets: [(label: String, size: Int, opacity: Int, texture: Int)] {
        var low = (label: "Low", size: 0, opacity: 0, texture: 0)
        var mid = (label: "Mid", size: 0, opacity: 0, texture: 0)
        var high = (label: "High", size: 0, opacity: 0, texture: 0)

        for brush in brushes {
            switch brush.size {
            case ..<16: low.size += 1
            case ..<32: mid.size += 1
            default: high.size += 1
            }
            switch brush.opacity {
            case ..<0.45: low.opacity += 1
            case ..<0.75: mid.opacity += 1
            default: high.opacity += 1
            }
            switch brush.texture {
            case ..<0.33: low.texture += 1
            case ..<0.66: mid.texture += 1
            default: high.texture += 1
            }
        }
        return [low, mid, high]
    }

    var weeklyRecap: WeeklyRecap {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStart = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        let created = brushes.filter { $0.createdAt >= weekStart }.count
        var usage = 0
        var activeDays = 0
        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let count = dailyUsage[Self.dayKey(from: day), default: 0]
            usage += count
            if count > 0 { activeDays += 1 }
        }
        let top = usageByBrush.first?.brush.name
        let favorites = brushes.filter(\.isFavorite).count
        return WeeklyRecap(
            brushesCreated: created,
            usageEvents: usage,
            topBrushName: top,
            favoriteCount: favorites,
            activeDays: activeDays,
            streak: streak
        )
    }

    func filteredBrushes(
        search: String,
        sort: LibrarySort,
        tag: BrushTag?,
        favoritesOnly: Bool
    ) -> [BrushItem] {
        var result = brushes
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(query) || $0.tag.title.lowercased().contains(query)
            }
        }
        if let tag {
            result = result.filter { $0.tag == tag }
        }
        if favoritesOnly {
            result = result.filter(\.isFavorite)
        }
        switch sort {
        case .newest:
            result.sort { $0.createdAt > $1.createdAt }
        case .name:
            result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .usage:
            result.sort { $0.usageCount > $1.usageCount }
        case .favoritesFirst:
            result.sort {
                if $0.isFavorite != $1.isFavorite { return $0.isFavorite && !$1.isFavorite }
                return $0.createdAt > $1.createdAt
            }
        }
        return result
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: Keys.onboarding)
        HapticFeedback.success()
    }

    func pushDesignerUndo() {
        guard !suppressHistory else { return }
        insertUndoSnapshot(designerSnapshot)
    }

    func insertUndoSnapshot(_ snapshot: DesignerSnapshot) {
        guard !suppressHistory else { return }
        if undoStack.last == snapshot { return }
        undoStack.append(snapshot)
        if undoStack.count > 40 { undoStack.removeFirst() }
        redoStack.removeAll()
    }

    func undoDesigner() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(designerSnapshot)
        applySnapshot(previous)
        HapticFeedback.selection()
    }

    func redoDesigner() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(designerSnapshot)
        applySnapshot(next)
        HapticFeedback.selection()
    }

    func applyPreset(_ preset: BrushPreset) {
        pushDesignerUndo()
        designerSize = preset.size
        designerOpacity = preset.opacity
        designerTexture = preset.texture
        designerTag = preset.tag
        designerColorHex = preset.colorHex
        if designerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            designerName = preset.title
        }
        markPresetUsed()
        HapticFeedback.selection()
    }

    func randomizeDesigner() {
        pushDesignerUndo()
        designerSize = Double.random(in: 6...42)
        designerOpacity = Double.random(in: 0.3...1)
        designerTexture = Double.random(in: 0...1)
        designerTag = BrushTag.allCases.randomElement() ?? .custom
        let palette = ["59BB75", "5B8DEF", "FF6B4A", "F2F2F7", "C084FC", "FBBF24", "1C1C1E"]
        designerColorHex = palette.randomElement() ?? "59BB75"
        HapticFeedback.success()
    }

    func saveBrushFromDesigner() {
        let trimmed = designerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? defaultBrushName() : trimmed
        let brush = BrushItem(
            name: name,
            size: designerSize,
            opacity: designerOpacity,
            texture: designerTexture,
            usageCount: 1,
            tag: designerTag,
            colorHex: designerColorHex
        )
        brushes.insert(brush, at: 0)
        itemsCreated += 1
        totalUsageEvents += 1
        bumpDailyUsage()
        registerActivityDay()
        persistBrushes()
        persistCounters()
        advanceChallenge(kind: .createBrush)
        if usedPresetToday {
            advanceChallenge(kind: .tryPreset)
        }
        if brush.tag != .custom {
            advanceChallenge(kind: .tagBrush)
        }
        designerName = ""
        HapticFeedback.success()
    }

    func updateBrush(_ brush: BrushItem) {
        guard let index = brushes.firstIndex(where: { $0.id == brush.id }) else { return }
        let previousTag = brushes[index].tag
        brushes[index] = brush
        persistBrushes()
        if brush.tag != .custom && brush.tag != previousTag {
            advanceChallenge(kind: .tagBrush)
        }
        HapticFeedback.lightTap()
    }

    func toggleFavorite(id: UUID) {
        guard let index = brushes.firstIndex(where: { $0.id == id }) else { return }
        brushes[index].isFavorite.toggle()
        persistBrushes()
        HapticFeedback.selection()
    }

    func duplicateBrush(id: UUID) {
        guard let original = brushes.first(where: { $0.id == id }) else { return }
        var copy = original
        copy.id = UUID()
        copy.name = original.name + " Copy"
        copy.createdAt = Date()
        copy.usageCount = 0
        copy.isFavorite = false
        brushes.insert(copy, at: 0)
        itemsCreated += 1
        persistBrushes()
        persistCounters()
        HapticFeedback.success()
    }

    func deleteBrush(at offsets: IndexSet) {
        brushes.remove(atOffsets: offsets)
        persistBrushes()
        HapticFeedback.warning()
    }

    func deleteBrush(id: UUID) {
        brushes.removeAll { $0.id == id }
        persistBrushes()
        HapticFeedback.warning()
    }

    func deleteBrushes(ids: [UUID]) {
        brushes.removeAll { ids.contains($0.id) }
        persistBrushes()
        HapticFeedback.warning()
    }

    func recordBrushUsage(id: UUID) {
        guard let index = brushes.firstIndex(where: { $0.id == id }) else { return }
        brushes[index].usageCount += 1
        totalUsageEvents += 1
        bumpDailyUsage()
        registerActivityDay()
        persistBrushes()
        persistCounters()
        if brushes[index].isFavorite {
            advanceChallenge(kind: .useFavorite)
        }
        HapticFeedback.success()
    }

    func applyBrushToDesigner(_ brush: BrushItem) {
        pushDesignerUndo()
        designerSize = brush.size
        designerOpacity = brush.opacity
        designerTexture = brush.texture
        designerName = brush.name
        designerTag = brush.tag
        designerColorHex = brush.colorHex
        HapticFeedback.selection()
    }

    func recordPracticeStroke() {
        refreshChallengeDay()
        practiceStrokeCountToday += 1
        defaults.set(Self.dayKey(from: Date()), forKey: Keys.practiceStrokes)
        defaults.set(practiceStrokeCountToday, forKey: Keys.practiceCount)
        if practiceStrokeCountToday >= todayChallenge.target {
            advanceChallenge(kind: .practiceStroke, amount: practiceStrokeCountToday)
        }
    }

    func markCompareOpened() {
        advanceChallenge(kind: .compareBrushes)
    }

    func resetAllData() {
        brushes = []
        hasCompletedOnboarding = false
        itemsCreated = 0
        sessionCount = 0
        streak = 0
        totalUsageEvents = 0
        dailyUsage = [:]
        challengeProgress = 0
        challengeCompletedDay = nil
        usedPresetToday = false
        practiceStrokeCountToday = 0
        designerSize = 24
        designerOpacity = 0.85
        designerTexture = 0.5
        designerName = ""
        designerTag = .custom
        designerColorHex = "59BB75"
        undoStack = []
        redoStack = []
        lastActivityDayKey = nil
        lastSessionRecordedDay = nil
        defaults.removeObject(forKey: Keys.brushes)
        defaults.removeObject(forKey: Keys.onboarding)
        defaults.removeObject(forKey: Keys.itemsCreated)
        defaults.removeObject(forKey: Keys.sessionCount)
        defaults.removeObject(forKey: Keys.streak)
        defaults.removeObject(forKey: Keys.totalUsage)
        defaults.removeObject(forKey: Keys.lastActivity)
        defaults.removeObject(forKey: Keys.previousActivity)
        defaults.removeObject(forKey: Keys.dailyUsage)
        defaults.removeObject(forKey: Keys.challengeProgress)
        defaults.removeObject(forKey: Keys.challengeDay)
        defaults.removeObject(forKey: Keys.challengeCompleted)
        defaults.removeObject(forKey: Keys.usedPreset)
        defaults.removeObject(forKey: Keys.practiceStrokes)
        defaults.removeObject(forKey: Keys.practiceCount)
        NotificationCenter.default.post(name: .dataReset, object: nil)
        HapticFeedback.warning()
    }

    private func applySnapshot(_ snapshot: DesignerSnapshot) {
        suppressHistory = true
        designerSize = snapshot.size
        designerOpacity = snapshot.opacity
        designerTexture = snapshot.texture
        designerName = snapshot.name
        designerTag = snapshot.tag
        designerColorHex = snapshot.colorHex
        suppressHistory = false
    }

    private func markPresetUsed() {
        let today = Self.dayKey(from: Date())
        usedPresetToday = true
        defaults.set(today, forKey: Keys.usedPreset)
    }

    private func advanceChallenge(kind: ChallengeKind, amount: Int = 1) {
        refreshChallengeDay()
        guard !isChallengeComplete else { return }
        guard todayChallenge.kind == kind else { return }
        challengeProgress = min(todayChallenge.target, max(challengeProgress, amount))
        defaults.set(challengeProgress, forKey: Keys.challengeProgress)
        if challengeProgress >= todayChallenge.target {
            challengeCompletedDay = Self.dayKey(from: Date())
            defaults.set(challengeCompletedDay, forKey: Keys.challengeCompleted)
            HapticFeedback.success()
        }
    }

    private func refreshChallengeDay() {
        let today = Self.dayKey(from: Date())
        let storedDay = defaults.string(forKey: Keys.challengeDay)
        if storedDay != today {
            defaults.set(today, forKey: Keys.challengeDay)
            challengeProgress = 0
            defaults.set(0, forKey: Keys.challengeProgress)
            usedPresetToday = false
            practiceStrokeCountToday = 0
            defaults.set(0, forKey: Keys.practiceCount)
        } else {
            challengeProgress = defaults.integer(forKey: Keys.challengeProgress)
            challengeCompletedDay = defaults.string(forKey: Keys.challengeCompleted)
            usedPresetToday = defaults.string(forKey: Keys.usedPreset) == today
            if defaults.string(forKey: Keys.practiceStrokes) == today {
                practiceStrokeCountToday = defaults.integer(forKey: Keys.practiceCount)
            }
        }
    }

    private func defaultBrushName() -> String {
        "Brush \(itemsCreated + 1)"
    }

    private func bumpDailyUsage() {
        let today = Self.dayKey(from: Date())
        dailyUsage[today, default: 0] += 1
        persistDailyUsage()
    }

    private func load() {
        hasCompletedOnboarding = defaults.bool(forKey: Keys.onboarding)
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        sessionCount = defaults.integer(forKey: Keys.sessionCount)
        streak = defaults.integer(forKey: Keys.streak)
        totalUsageEvents = defaults.integer(forKey: Keys.totalUsage)
        lastActivityDayKey = defaults.string(forKey: Keys.lastActivity)
        challengeCompletedDay = defaults.string(forKey: Keys.challengeCompleted)
        if let data = defaults.data(forKey: Keys.brushes),
           let decoded = try? JSONDecoder().decode([BrushItem].self, from: data) {
            brushes = decoded
        }
        if let data = defaults.data(forKey: Keys.dailyUsage),
           let decoded = try? JSONDecoder().decode([String: Int].self, from: data) {
            dailyUsage = decoded
        } else if totalUsageEvents > 0 {
            dailyUsage[Self.dayKey(from: Date())] = totalUsageEvents
            persistDailyUsage()
        }
    }

    private func persistBrushes() {
        if let data = try? JSONEncoder().encode(brushes) {
            defaults.set(data, forKey: Keys.brushes)
        }
    }

    private func persistDailyUsage() {
        if let data = try? JSONEncoder().encode(dailyUsage) {
            defaults.set(data, forKey: Keys.dailyUsage)
        }
    }

    private func persistCounters() {
        defaults.set(itemsCreated, forKey: Keys.itemsCreated)
        defaults.set(sessionCount, forKey: Keys.sessionCount)
        defaults.set(streak, forKey: Keys.streak)
        defaults.set(totalUsageEvents, forKey: Keys.totalUsage)
        if let lastActivityDayKey {
            defaults.set(lastActivityDayKey, forKey: Keys.lastActivity)
        }
    }

    private func registerActivityDay() {
        let today = Self.dayKey(from: Date())
        guard lastActivityDayKey != today else { return }
        if let last = lastActivityDayKey {
            defaults.set(last, forKey: Keys.previousActivity)
            if Self.isConsecutiveDay(previous: last, next: today) {
                streak = max(streak + 1, 1)
            } else if last != today {
                streak = 1
            }
        } else {
            streak = max(streak, 1)
        }
        lastActivityDayKey = today
        persistCounters()
    }

    private func recordSessionIfNeeded() {
        let today = Self.dayKey(from: Date())
        guard lastSessionRecordedDay != today else { return }
        lastSessionRecordedDay = today
        sessionCount += 1
        registerActivityDay()
        defaults.set(sessionCount, forKey: Keys.sessionCount)
    }

    private static func dayKey(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func isConsecutiveDay(previous: String, next: String) -> Bool {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        guard let prevDate = formatter.date(from: previous),
              let nextDate = formatter.date(from: next) else { return false }
        let dayDiff = Calendar.current.dateComponents([.day], from: prevDate, to: nextDate).day
        return dayDiff == 1
    }
}
