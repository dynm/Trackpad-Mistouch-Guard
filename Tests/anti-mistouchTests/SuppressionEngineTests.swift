import Foundation
import Testing
@testable import anti_mistouch

@Test func suppressesPointerEventsInsideWindow() async throws {
    let engine = SuppressionEngine(isEnabled: true, suppressionInterval: 0.35)
    let start = Date(timeIntervalSinceReferenceDate: 100)

    engine.recordKeystroke(at: start)

    #expect(engine.shouldSuppressPointerEvent(at: start.addingTimeInterval(0.2)))
    #expect(!engine.shouldSuppressPointerEvent(at: start.addingTimeInterval(0.5)))
}

@Test func disabledEngineNeverSuppresses() async throws {
    let engine = SuppressionEngine(isEnabled: false, suppressionInterval: 0.35)
    let start = Date(timeIntervalSinceReferenceDate: 100)

    engine.recordKeystroke(at: start)

    #expect(!engine.shouldSuppressPointerEvent(at: start.addingTimeInterval(0.1)))
}

@Test func countsOnlyOneGuardPerTypingWindow() async throws {
    let engine = SuppressionEngine(isEnabled: true, suppressionInterval: 0.35)
    let start = Date(timeIntervalSinceReferenceDate: 100)

    engine.recordKeystroke(at: start)

    #expect(engine.registerGuardIfNeeded(at: start.addingTimeInterval(0.1)))
    #expect(!engine.registerGuardIfNeeded(at: start.addingTimeInterval(0.2)))
    #expect(!engine.registerGuardIfNeeded(at: start.addingTimeInterval(0.5)))

    engine.recordKeystroke(at: start.addingTimeInterval(0.6))

    #expect(engine.registerGuardIfNeeded(at: start.addingTimeInterval(0.7)))
}

@Test func continuousTypingCannotExtendSuppressionIndefinitely() async throws {
    let engine = SuppressionEngine(
        isEnabled: true,
        suppressionInterval: 0.35,
        maxContinuousSuppressionInterval: 1.0
    )
    let start = Date(timeIntervalSinceReferenceDate: 100)

    engine.recordKeystroke(at: start)
    engine.recordKeystroke(at: start.addingTimeInterval(0.2))
    engine.recordKeystroke(at: start.addingTimeInterval(0.4))
    engine.recordKeystroke(at: start.addingTimeInterval(0.6))
    engine.recordKeystroke(at: start.addingTimeInterval(0.8))

    #expect(engine.shouldSuppressPointerEvent(at: start.addingTimeInterval(0.95)))
    #expect(!engine.shouldSuppressPointerEvent(at: start.addingTimeInterval(1.05)))
}

@Test func disablingClearsPendingSuppressionImmediately() async throws {
    let engine = SuppressionEngine(isEnabled: true, suppressionInterval: 0.35)
    let start = Date(timeIntervalSinceReferenceDate: 100)

    engine.recordKeystroke(at: start)
    #expect(engine.shouldSuppressPointerEvent(at: start.addingTimeInterval(0.1)))

    engine.configure(isEnabled: false, suppressionInterval: 0.35)

    #expect(!engine.shouldSuppressPointerEvent(at: start.addingTimeInterval(0.15)))
}
