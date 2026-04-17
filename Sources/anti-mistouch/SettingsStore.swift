import Foundation
import CoreGraphics

final class SettingsStore {
    private enum Key {
        static let isEnabled = "isEnabled"
        static let suppressionInterval = "suppressionInterval"
        static let ignoredKeyCodes = "ignoredKeyCodes"
        static let guardCount = "guardCount"
        static let showsGuardCountInMenuBar = "showsGuardCountInMenuBar"
    }

    private let defaults: UserDefaults
    var onChange: (() -> Void)?
    var onGuardCountIncrement: (() -> Void)?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.isEnabled: true,
            Key.suppressionInterval: 0.35,
            Key.ignoredKeyCodes: [UInt16]([56, 58, 59, 60, 61, 62, 63]),
            Key.guardCount: 0,
            Key.showsGuardCountInMenuBar: true,
        ])
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: Key.isEnabled) }
        set {
            defaults.set(newValue, forKey: Key.isEnabled)
            onChange?()
        }
    }

    var suppressionInterval: TimeInterval {
        get { defaults.double(forKey: Key.suppressionInterval) }
        set {
            defaults.set(newValue, forKey: Key.suppressionInterval)
            onChange?()
        }
    }

    var ignoredKeyCodes: Set<CGKeyCode> {
        let stored = defaults.array(forKey: Key.ignoredKeyCodes) as? [UInt16] ?? []
        return Set(stored.map { CGKeyCode($0) })
    }

    var guardCount: Int {
        defaults.integer(forKey: Key.guardCount)
    }

    var showsGuardCountInMenuBar: Bool {
        get { defaults.bool(forKey: Key.showsGuardCountInMenuBar) }
        set {
            defaults.set(newValue, forKey: Key.showsGuardCountInMenuBar)
            onChange?()
        }
    }

    func incrementGuardCount() {
        defaults.set(guardCount + 1, forKey: Key.guardCount)
        onChange?()
        onGuardCountIncrement?()
    }

    func resetGuardCount() {
        defaults.set(0, forKey: Key.guardCount)
        onChange?()
    }
}
