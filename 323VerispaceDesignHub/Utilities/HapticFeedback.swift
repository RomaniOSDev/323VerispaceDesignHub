import AudioToolbox
import UIKit

enum HapticFeedback {
    private static var soundEnabled: Bool {
        if UserDefaults.standard.object(forKey: AppStore.PreferenceKeys.soundEnabled) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: AppStore.PreferenceKeys.soundEnabled)
    }

    private static var hapticsEnabled: Bool {
        if UserDefaults.standard.object(forKey: AppStore.PreferenceKeys.hapticsEnabled) == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: AppStore.PreferenceKeys.hapticsEnabled)
    }

    static func lightTap() {
        if hapticsEnabled {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        playSound(1104)
    }

    static func success() {
        if hapticsEnabled {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        playSound(1057)
    }

    static func selection() {
        if hapticsEnabled {
            UISelectionFeedbackGenerator().selectionChanged()
        }
        playSound(1156)
    }

    static func warning() {
        if hapticsEnabled {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        playSound(1053)
    }

    private static func playSound(_ id: SystemSoundID) {
        guard soundEnabled else { return }
        AudioServicesPlaySystemSound(id)
    }
}
