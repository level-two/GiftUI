import GiftUI
import GiftUIDrawing
import GiftUIDrawingFailureAdapterFixture
import GiftUIFailureCore

/// Independent SPEC-012 access and failure-adapter expectations.
public func giftuiP06ErrorMappings() -> UInt32 {
    var checks: UInt32 = 0
    func expect(_ condition: Bool) {
        checks += 1
        precondition(condition)
    }

    expect(DrawingError(accessFailure: .wrongOwner) == .invalidModelAccess)
    expect(DrawingError(accessFailure: .wrongSchema) == .invalidModelAccess)
    expect(DrawingError(accessFailure: .staleModel) == .invalidModelAccess)
    expect(DrawingError(accessFailure: .invalidPhase) == .invalidPhase)
    expect(DrawingError(accessFailure: .outOfBounds) == .invalidValue)
    expect(DrawingProductionError.invalidModelAccess.rawValue == 9)
    expect(DrawingProductionError(rawValue: 9) == .invalidModelAccess)
    expect(MemoryLayout<DrawingProductionError>.size == 1)
    expect(MemoryLayout<DrawingProductionError>.stride == 1)

    let fact = GiftUIDrawingFailureAdapterFixture.fact(for: .invalidModelAccess)
    expect(fact.condition == .invalidIdentity)
    expect(fact.origin == .rendering)
    expect(fact.affectedScope == .activeCycle)
    expect(fact.containment == .contained)
    return checks
}
