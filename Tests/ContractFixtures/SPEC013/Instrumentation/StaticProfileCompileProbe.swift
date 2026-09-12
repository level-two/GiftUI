import GiftUI
import GiftUIRuntimeCore
import GiftUIRuntimeStatic

private enum CompileProbeIdentity: UInt8, Equatable, Sendable {
    case root = 1
}

private struct CompileProbeCapture: Sendable {
    let color: Color
    let scalar: GeometryScalar
}

@_cdecl("giftui_spec013_layout_limits")
public func spec013LayoutLimits() -> UInt32 {
    UInt32(MemoryLayout<RuntimeProfileLimits>.size)
}

@_cdecl("giftui_spec013_layout_audit")
public func spec013LayoutAudit() -> UInt32 {
    UInt32(MemoryLayout<RuntimeStorageAudit>.size)
}

@_cdecl("giftui_spec013_layout_identity")
public func spec013LayoutIdentity() -> UInt32 {
    UInt32(MemoryLayout<StaticStructuralIdentity>.size)
}

@_cdecl("giftui_spec013_layout_occurrence")
public func spec013LayoutOccurrence() -> UInt32 {
    UInt32(
        MemoryLayout<
            StaticCanvasOccurrence<CompileProbeIdentity, CompileProbeCapture>
        >.size
    )
}

public func spec013StaticProfileLayoutChecksum() -> UInt32 {
    StaticStructuralIdentity(rawValue: 1)!.rawValue
        &+ spec013LayoutLimits()
        &+ spec013LayoutAudit()
        &+ spec013LayoutIdentity()
        &+ spec013LayoutOccurrence()
}
