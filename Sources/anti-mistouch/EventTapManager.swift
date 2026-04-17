import ApplicationServices
import Foundation

final class EventTapManager {
    enum Status: Equatable {
        case stopped
        case active
        case failedToCreateTap
    }

    var onAuthorizationRevoked: (() -> Void)?

    private let settingsStore: SettingsStore
    private let suppressionEngine: SuppressionEngine
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var hasHandledAuthorizationRevocation = false
    private(set) var status: Status = .stopped

    init(settingsStore: SettingsStore, suppressionEngine: SuppressionEngine) {
        self.settingsStore = settingsStore
        self.suppressionEngine = suppressionEngine
    }

    func start() {
        stop()
        hasHandledAuthorizationRevocation = false

        let eventTypes: [CGEventType] = [
            .keyDown,
            .mouseMoved,
            .leftMouseDown,
            .leftMouseUp,
            .rightMouseDown,
            .rightMouseUp,
            .otherMouseDown,
            .otherMouseUp,
            .leftMouseDragged,
            .rightMouseDragged,
            .otherMouseDragged,
            .scrollWheel,
        ]
        let eventMask = eventTypes.reduce(CGEventMask(0)) { partialResult, eventType in
            partialResult | (CGEventMask(1) << eventType.rawValue)
        }

        let callback: CGEventTapCallBack = { proxy, type, event, userInfo in
            guard let userInfo else { return Unmanaged.passUnretained(event) }
            let manager = Unmanaged<EventTapManager>.fromOpaque(userInfo).takeUnretainedValue()
            return manager.handle(proxy: proxy, type: type, event: event)
        }

        let userInfo = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: userInfo
        )

        guard let eventTap else {
            status = .failedToCreateTap
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        CGEvent.tapEnable(tap: eventTap, enable: true)
        status = .active
    }

    func stop() {
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        runLoopSource = nil
        eventTap = nil
        status = .stopped
    }

    private func handle(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        guard AXIsProcessTrusted() else {
            handleAuthorizationRevoked()
            return Unmanaged.passUnretained(event)
        }

        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
                status = .active
            }
            return Unmanaged.passUnretained(event)
        case .keyDown:
            handleKeyDown(event)
            return Unmanaged.passUnretained(event)
        case .mouseMoved,
             .leftMouseDown,
             .leftMouseUp,
             .rightMouseDown,
             .rightMouseUp,
             .otherMouseDown,
             .otherMouseUp,
             .leftMouseDragged,
             .rightMouseDragged,
             .otherMouseDragged,
             .scrollWheel:
            let now = Date()
            guard suppressionEngine.shouldSuppressPointerEvent(at: now) else {
                return Unmanaged.passUnretained(event)
            }
            if suppressionEngine.registerGuardIfNeeded(at: now) {
                settingsStore.incrementGuardCount()
            }
            return nil
        default:
            return Unmanaged.passUnretained(event)
        }
    }

    private func handleKeyDown(_ event: CGEvent) {
        let isAutorepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
        guard !isAutorepeat else { return }

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
        guard !settingsStore.ignoredKeyCodes.contains(keyCode) else { return }
        suppressionEngine.recordKeystroke(at: Date())
    }

    private func handleAuthorizationRevoked() {
        guard !hasHandledAuthorizationRevocation else { return }
        hasHandledAuthorizationRevocation = true
        let onAuthorizationRevoked = onAuthorizationRevoked
        stop()
        onAuthorizationRevoked?()
    }
}
