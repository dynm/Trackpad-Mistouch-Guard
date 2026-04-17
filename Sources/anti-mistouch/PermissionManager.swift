import ApplicationServices
import Foundation

@MainActor
final class PermissionManager {
    private enum Monitoring {
        static let pollInterval: TimeInterval = 2.0
    }

    var onAccessibilityChange: ((Bool) -> Void)?

    private var pollTimer: Timer?
    private var lastAccessibilityGranted: Bool?

    var accessibilityGranted: Bool {
        AXIsProcessTrusted()
    }

    func requestAccessibilityIfNeeded() {
        let promptKey = "AXTrustedCheckOptionPrompt" as CFString
        let options = [promptKey: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    func startMonitoring() {
        stopMonitoring()

        lastAccessibilityGranted = accessibilityGranted
        pollTimer = Timer.scheduledTimer(withTimeInterval: Monitoring.pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.pollAccessibilityStatus()
            }
        }
        if let pollTimer {
            RunLoop.main.add(pollTimer, forMode: .common)
        }
    }

    func stopMonitoring() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    private func pollAccessibilityStatus() {
        let currentValue = accessibilityGranted
        guard currentValue != lastAccessibilityGranted else { return }

        lastAccessibilityGranted = currentValue
        onAccessibilityChange?(currentValue)
    }
}
