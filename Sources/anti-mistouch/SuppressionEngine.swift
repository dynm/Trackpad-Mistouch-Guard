import Foundation

final class SuppressionEngine {
    private let maxContinuousSuppressionInterval: TimeInterval
    private(set) var isEnabled: Bool
    private(set) var suppressionInterval: TimeInterval
    private var lastKeystrokeAt: Date?
    private var suppressionWindowStartedAt: Date?
    private var hasCountedCurrentSuppressionWindow = false

    init(
        isEnabled: Bool,
        suppressionInterval: TimeInterval,
        maxContinuousSuppressionInterval: TimeInterval = 1.5
    ) {
        self.isEnabled = isEnabled
        self.suppressionInterval = suppressionInterval
        self.maxContinuousSuppressionInterval = maxContinuousSuppressionInterval
    }

    func configure(isEnabled: Bool, suppressionInterval: TimeInterval) {
        self.isEnabled = isEnabled
        self.suppressionInterval = suppressionInterval
        if !isEnabled {
            lastKeystrokeAt = nil
            suppressionWindowStartedAt = nil
            hasCountedCurrentSuppressionWindow = false
        }
    }

    func recordKeystroke(at date: Date) {
        guard isEnabled else { return }
        if let lastKeystrokeAt,
           date.timeIntervalSince(lastKeystrokeAt) >= suppressionInterval {
            suppressionWindowStartedAt = date
        } else if suppressionWindowStartedAt == nil {
            suppressionWindowStartedAt = date
        }
        lastKeystrokeAt = date
        hasCountedCurrentSuppressionWindow = false
    }

    func shouldSuppressPointerEvent(at date: Date) -> Bool {
        guard
            isEnabled,
            let lastKeystrokeAt,
            let suppressionWindowStartedAt
        else {
            return false
        }

        let isInsideKeystrokeWindow = date.timeIntervalSince(lastKeystrokeAt) < suppressionInterval
        let isInsideContinuousGuardWindow = date.timeIntervalSince(suppressionWindowStartedAt) < maxContinuousSuppressionInterval

        guard isInsideKeystrokeWindow, isInsideContinuousGuardWindow else {
            if !isInsideContinuousGuardWindow {
                self.suppressionWindowStartedAt = nil
                self.lastKeystrokeAt = nil
            }
            return false
        }

        return true
    }

    func registerGuardIfNeeded(at date: Date) -> Bool {
        guard shouldSuppressPointerEvent(at: date) else {
            hasCountedCurrentSuppressionWindow = false
            return false
        }

        guard !hasCountedCurrentSuppressionWindow else { return false }
        hasCountedCurrentSuppressionWindow = true
        return true
    }
}
