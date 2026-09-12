import GiftUI
import GiftUIDrawing
import GiftUIInteraction
import GiftUIRuntimeCore

package protocol StaticObservableSlotMetadata {
    associatedtype StructuralIdentity: Equatable & Sendable

    var slotCount: UInt16 { get }
    func structuralIdentity(for slot: UInt16) -> StructuralIdentity?
}

package protocol StaticCanvasCoverageMetadata {
    var declaredEntryCount: UInt16 { get }
    var maximumDeclaredID: UInt16 { get }
    func coverageMultiplicity(for id: UInt16) -> UInt8
}

package struct StaticActionSpecialization<Action: GiftUIAction>: Sendable {
    package init() {}

    package func decode(_ action: BoundedApplicationAction) -> Action? {
        guard let decoded = Action(rawValue: action.code), decoded.rawValue == action.code else {
            return nil
        }
        return decoded
    }
}

package struct StaticGeneratedProfileMetadata<Slots, Action, CanvasTable, Coverage>:
    RuntimeStaticCanvasAuditMetadata
where
    Slots: StaticObservableSlotMetadata,
    Action: GiftUIAction,
    CanvasTable: StaticCanvasCallableTable,
    Coverage: StaticCanvasCoverageMetadata
{
    package let observableSlots: Slots
    package let actionSpecialization: StaticActionSpecialization<Action>
    package var canvasTable: CanvasTable
    package let canvasCoverage: Coverage

    package init?(
        observableSlots: Slots,
        action: Action.Type,
        canvasTable: consuming CanvasTable,
        canvasCoverage: Coverage
    ) {
        guard observableSlots.slotCount > 0 else { return nil }
        var slot: UInt16 = 0
        while slot < observableSlots.slotCount {
            guard let identity = observableSlots.structuralIdentity(for: slot) else {
                return nil
            }
            var earlier: UInt16 = 0
            while earlier < slot {
                guard observableSlots.structuralIdentity(for: earlier) != identity else {
                    return nil
                }
                earlier += 1
            }
            slot += 1
        }
        guard observableSlots.structuralIdentity(for: observableSlots.slotCount) == nil else {
            return nil
        }

        self.observableSlots = observableSlots
        actionSpecialization = StaticActionSpecialization<Action>()
        self.canvasTable = consume canvasTable
        self.canvasCoverage = canvasCoverage
        _ = action
    }

    package var callableCaseCount: UInt16 {
        canvasTable.callableCaseCount
    }

    package var declaredEntryCount: UInt16 {
        canvasCoverage.declaredEntryCount
    }

    package var maximumDeclaredID: UInt16 {
        canvasCoverage.maximumDeclaredID
    }

    package func coverageMultiplicity(for id: UInt16) -> UInt8 {
        canvasCoverage.coverageMultiplicity(for: id)
    }

    package func captureByteCount(for id: UInt16) -> UInt16? {
        canvasTable.captureByteCount(for: id)
    }
}
