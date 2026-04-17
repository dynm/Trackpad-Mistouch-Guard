import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
    init(
        settingsStore: SettingsStore,
        permissionManager: PermissionManager,
        eventTapManager: EventTapManager
    ) {
        let rootView = SettingsView(
            viewModel: SettingsViewModel(
                settingsStore: settingsStore,
                permissionManager: permissionManager,
                eventTapManager: eventTapManager
            )
        )
        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Mistouch Guard"
        window.setContentSize(NSSize(width: 440, height: 320))
        window.styleMask.insert(.closable)
        window.styleMask.insert(.titled)
        window.isReleasedWhenClosed = false
        super.init(window: window)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var isEnabled: Bool
    @Published var suppressionIntervalMs: Double

    private let settingsStore: SettingsStore
    private let permissionManager: PermissionManager
    private let eventTapManager: EventTapManager

    init(
        settingsStore: SettingsStore,
        permissionManager: PermissionManager,
        eventTapManager: EventTapManager
    ) {
        self.settingsStore = settingsStore
        self.permissionManager = permissionManager
        self.eventTapManager = eventTapManager
        isEnabled = settingsStore.isEnabled
        suppressionIntervalMs = settingsStore.suppressionInterval * 1000
    }

    var accessibilityStatusText: String {
        permissionManager.accessibilityGranted ? "Granted" : "Required"
    }

    var captureStatusText: String {
        switch eventTapManager.status {
        case .active: return "Running"
        case .failedToCreateTap: return "Failed to capture events"
        case .stopped: return "Stopped"
        }
    }

    func commitEnabled() {
        settingsStore.isEnabled = isEnabled
    }

    func commitInterval() {
        settingsStore.suppressionInterval = suppressionIntervalMs / 1000
    }

    func requestAccessibility() {
        permissionManager.requestAccessibilityIfNeeded()
        objectWillChange.send()
    }

    func restartCapture() {
        eventTapManager.start()
        objectWillChange.send()
    }
}

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Mistouch Guard")
                .font(.system(size: 24, weight: .semibold, design: .rounded))

            Toggle("Suppress accidental trackpad input while typing", isOn: $viewModel.isEnabled)
                .onChange(of: viewModel.isEnabled) { _ in
                    viewModel.commitEnabled()
                }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Suppression window")
                    Spacer()
                    Text("\(Int(viewModel.suppressionIntervalMs)) ms")
                        .foregroundStyle(.secondary)
                }
                Slider(value: $viewModel.suppressionIntervalMs, in: 100...1200, step: 25)
                    .onChange(of: viewModel.suppressionIntervalMs) { _ in
                        viewModel.commitInterval()
                    }
                Text("Shorter values feel less aggressive. Around 300-450 ms matches normal typing bursts.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            GroupBox("Permissions") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Accessibility")
                        Spacer()
                        Text(viewModel.accessibilityStatusText)
                    }
                    HStack {
                        Text("Event tap")
                        Spacer()
                        Text(viewModel.captureStatusText)
                    }
                    Text("If capture fails, grant Accessibility and Input Monitoring in System Settings, then restart the event tap.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Request Accessibility") {
                            viewModel.requestAccessibility()
                        }
                        Button("Restart Event Tap") {
                            viewModel.restartCapture()
                        }
                    }
                }
                .padding(.top, 4)
            }

            Spacer()
        }
        .padding(22)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color(red: 0.98, green: 0.96, blue: 0.91), Color(red: 0.92, green: 0.95, blue: 0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
