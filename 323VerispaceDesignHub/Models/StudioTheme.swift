import SwiftUI

enum StudioTheme: String, CaseIterable, Identifiable, Codable {
    case midnight
    case forest
    case ember
    case arctic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .midnight: return "Midnight"
        case .forest: return "Forest"
        case .ember: return "Ember"
        case .arctic: return "Arctic"
        }
    }

    var subtitle: String {
        switch self {
        case .midnight: return "Deep indigo studio"
        case .forest: return "Moss and teal"
        case .ember: return "Warm charcoal glow"
        case .arctic: return "Cool slate and ice"
        }
    }

    var background: Color {
        switch self {
        case .midnight: return Color(red: 0.20, green: 0.23, blue: 0.39)
        case .forest: return Color(red: 0.10, green: 0.18, blue: 0.16)
        case .ember: return Color(red: 0.18, green: 0.11, blue: 0.10)
        case .arctic: return Color(red: 0.12, green: 0.16, blue: 0.22)
        }
    }

    var surface: Color {
        switch self {
        case .midnight: return Color(red: 0.29, green: 0.33, blue: 0.47)
        case .forest: return Color(red: 0.16, green: 0.28, blue: 0.24)
        case .ember: return Color(red: 0.30, green: 0.18, blue: 0.15)
        case .arctic: return Color(red: 0.20, green: 0.26, blue: 0.34)
        }
    }

    var primary: Color {
        switch self {
        case .midnight: return Color(red: 0.18, green: 0.67, blue: 0.32)
        case .forest: return Color(red: 0.30, green: 0.78, blue: 0.55)
        case .ember: return Color(red: 0.93, green: 0.45, blue: 0.28)
        case .arctic: return Color(red: 0.40, green: 0.72, blue: 0.95)
        }
    }

    var accent: Color {
        switch self {
        case .midnight: return Color(red: 0.35, green: 0.73, blue: 0.46)
        case .forest: return Color(red: 0.55, green: 0.88, blue: 0.70)
        case .ember: return Color(red: 1.00, green: 0.70, blue: 0.40)
        case .arctic: return Color(red: 0.70, green: 0.88, blue: 1.00)
        }
    }

    var textPrimary: Color { .white }
    var textSecondary: Color { Color.white.opacity(0.65) }
    var overlayOpacity: Double { 0.38 }
}

private struct StudioThemeKey: EnvironmentKey {
    static let defaultValue: StudioTheme = .midnight
}

extension EnvironmentValues {
    var studioTheme: StudioTheme {
        get { self[StudioThemeKey.self] }
        set { self[StudioThemeKey.self] = newValue }
    }
}
