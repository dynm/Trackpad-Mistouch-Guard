import AppKit
import QuartzCore

@MainActor
final class StatusItemController: NSObject {
    private enum Animation {
        static let flashDuration: CFTimeInterval = 2.0
        static let flashColor = NSColor.systemRed.withAlphaComponent(0.78).cgColor
        static let clearColor = NSColor.clear.cgColor
        static let cornerRadius: CGFloat = 7
    }

    private let settingsStore: SettingsStore
    private let permissionManager: PermissionManager
    private let eventTapManager: EventTapManager
    private let showSettings: () -> Void

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    init(
        settingsStore: SettingsStore,
        permissionManager: PermissionManager,
        eventTapManager: EventTapManager,
        showSettings: @escaping () -> Void
    ) {
        self.settingsStore = settingsStore
        self.permissionManager = permissionManager
        self.eventTapManager = eventTapManager
        self.showSettings = showSettings
    }

    func install() {
        refreshState()
    }

    func refreshState() {
        let menu = NSMenu()

        if let button = statusItem.button {
            button.image = AppLogo.makeStatusImage()
            button.imagePosition = .imageLeading
            button.title = statusItemLabel
            button.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .medium)
            button.contentTintColor = nil
            button.appearsDisabled = !settingsStore.isEnabled
            button.wantsLayer = true
            button.layer?.cornerRadius = Animation.cornerRadius
            button.layer?.backgroundColor = Animation.clearColor
            button.layer?.masksToBounds = true
        }

        let toggleTitle = settingsStore.isEnabled ? "Disable Guard" : "Enable Guard"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleGuard), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        let statusText: String
        switch eventTapManager.status {
        case .active:
            statusText = "Monitoring keyboard and trackpad events"
        case .failedToCreateTap:
            statusText = "Input monitoring is blocking event capture"
        case .stopped:
            statusText = permissionManager.accessibilityGranted ? "Protection is stopped" : "Accessibility permission was revoked"
        }
        let statusLabelItem = NSMenuItem(title: statusText, action: nil, keyEquivalent: "")
        statusLabelItem.isEnabled = false
        menu.addItem(statusLabelItem)

        let intervalItem = NSMenuItem(
            title: "Block for \(Int(settingsStore.suppressionInterval * 1000)) ms after typing",
            action: nil,
            keyEquivalent: ""
        )
        intervalItem.isEnabled = false
        menu.addItem(intervalItem)

        let guardCountItem = NSMenuItem(
            title: "Guarded accidental touches: \(settingsStore.guardCount)",
            action: nil,
            keyEquivalent: ""
        )
        guardCountItem.isEnabled = false
        menu.addItem(guardCountItem)

        let showGuardCountItem = NSMenuItem(
            title: "Show Count in Menu Bar",
            action: #selector(toggleGuardCountVisibility),
            keyEquivalent: ""
        )
        showGuardCountItem.target = self
        showGuardCountItem.state = settingsStore.showsGuardCountInMenuBar ? .on : .off
        menu.addItem(showGuardCountItem)

        let resetGuardCountItem = NSMenuItem(
            title: "Reset Guard Count",
            action: #selector(resetGuardCount),
            keyEquivalent: ""
        )
        resetGuardCountItem.target = self
        resetGuardCountItem.isEnabled = settingsStore.guardCount > 0
        menu.addItem(resetGuardCountItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let restartItem = NSMenuItem(title: "Restart Event Tap", action: #selector(restartTap), keyEquivalent: "r")
        restartItem.target = self
        menu.addItem(restartItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private var statusItemLabel: String {
        guard settingsStore.isEnabled else { return "Off" }
        guard settingsStore.showsGuardCountInMenuBar else { return "" }
        return " \(settingsStore.guardCount)"
    }
    @objc private func toggleGuard() {
        settingsStore.isEnabled.toggle()
    }

    @objc private func openSettings() {
        showSettings()
    }

    @objc private func toggleGuardCountVisibility() {
        settingsStore.showsGuardCountInMenuBar.toggle()
    }

    @objc private func resetGuardCount() {
        settingsStore.resetGuardCount()
    }

    @objc private func restartTap() {
        eventTapManager.start()
        refreshState()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }

    func animateGuardCapture() {
        guard let button = statusItem.button, let layer = button.layer else { return }

        layer.removeAnimation(forKey: "guard-capture-flash")
        layer.backgroundColor = Animation.flashColor

        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = Animation.flashColor
        animation.toValue = Animation.clearColor
        animation.duration = Animation.flashDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        layer.add(animation, forKey: "guard-capture-flash")

        layer.backgroundColor = Animation.clearColor
    }
}
