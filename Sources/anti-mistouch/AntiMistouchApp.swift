import AppKit

@MainActor
@main
final class AntiMistouchApp: NSObject, NSApplicationDelegate {
    private let settingsStore = SettingsStore()
    private lazy var suppressionEngine = SuppressionEngine(
        isEnabled: settingsStore.isEnabled,
        suppressionInterval: settingsStore.suppressionInterval
    )
    private lazy var permissionManager = PermissionManager()
    private lazy var eventTapManager = EventTapManager(
        settingsStore: settingsStore,
        suppressionEngine: suppressionEngine
    )
    private lazy var statusItemController = StatusItemController(
        settingsStore: settingsStore,
        permissionManager: permissionManager,
        eventTapManager: eventTapManager,
        showSettings: { [weak self] in
            self?.showSettingsWindow()
        }
    )
    private lazy var settingsWindowController = SettingsWindowController(
        settingsStore: settingsStore,
        permissionManager: permissionManager,
        eventTapManager: eventTapManager
    )

    static func main() {
        let app = NSApplication.shared
        let delegate = AntiMistouchApp()
        app.delegate = delegate
        app.applicationIconImage = AppLogo.makeAppIcon()
        app.setActivationPolicy(.accessory)
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        settingsStore.onChange = { [weak self] in
            self?.applyCurrentConfiguration()
        }
        settingsStore.onGuardCountIncrement = { [weak self] in
            self?.statusItemController.animateGuardCapture()
        }
        eventTapManager.onAuthorizationRevoked = { [weak self] in
            guard let self else { return }

            if self.settingsStore.isEnabled {
                self.settingsStore.isEnabled = false
            } else {
                self.applyCurrentConfiguration()
            }
        }
        permissionManager.onAccessibilityChange = { [weak self] accessibilityGranted in
            guard let self else { return }

            if !accessibilityGranted, self.settingsStore.isEnabled {
                self.settingsStore.isEnabled = false
                return
            }

            self.applyCurrentConfiguration()
        }

        permissionManager.requestAccessibilityIfNeeded()
        applyCurrentConfiguration()
        statusItemController.install()
    }

    func applicationWillTerminate(_ notification: Notification) {
        permissionManager.stopMonitoring()
        eventTapManager.stop()
    }

    private func showSettingsWindow() {
        settingsWindowController.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func applyCurrentConfiguration() {
        suppressionEngine.configure(
            isEnabled: settingsStore.isEnabled,
            suppressionInterval: settingsStore.suppressionInterval
        )

        if settingsStore.isEnabled {
            permissionManager.startMonitoring()

            if permissionManager.accessibilityGranted {
                if eventTapManager.status != .active {
                    eventTapManager.start()
                }
            } else if eventTapManager.status != .stopped {
                eventTapManager.stop()
            }
        } else {
            permissionManager.stopMonitoring()
            if eventTapManager.status != .stopped {
                eventTapManager.stop()
            }
        }

        statusItemController.refreshState()
    }
}
