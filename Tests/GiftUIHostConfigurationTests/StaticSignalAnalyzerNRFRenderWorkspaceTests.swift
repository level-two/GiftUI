import GiftUI
import GiftUIHostConfiguration
import GiftUIRenderLowering
import Testing

@testable import SignalAnalyzerTargetHost

@Test func staticNRFRenderWorkspaceKeepsPublishedLayoutAndUsesOnlyScratchTail() {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    var storage = [UInt8](
        repeating: 0, count: StaticSignalAnalyzerNRFLayoutTextCodec.regionByteCount
    )
    storage.withUnsafeMutableBytes { region in
        region[0] = 0xA5
        region[StaticSignalAnalyzerNRFLayoutWorkspace.publishedMarkerOffset] = 1
        var workspace = StaticSignalAnalyzerNRFRenderWorkspace(
            region: region, capacity: preset.runtimeLimits.render,
            structuralCapacity: preset.runtimeLimits.renderWorkspace
        )!
        #expect(workspace.capacity == preset.runtimeLimits.render)
        #expect(workspace.structuralCapacity == preset.runtimeLimits.renderWorkspace)
        #expect({ workspace.visitSemanticScope(at: 0) == .invalid }())
        #expect({ workspace.acquire() }())
        #expect({ !workspace.acquire() }())
        #expect({ workspace.visitSemanticScope(at: 0) == .first }())
        #expect({ workspace.visitSemanticScope(at: 0) == .repeated }())
        #expect({ workspace.visitSemanticScope(at: 98) == .invalid }())
        #expect({ workspace.visitLayoutScope(at: 97) == .first }())
        #expect({ workspace.visitLayoutScope(at: 97) == .repeated }())
        #expect({ workspace.visitLayoutScope(at: 98) == .invalid }())
        let foreground = Color(red: 17, green: 34, blue: 51)
        #expect({ workspace.pushForeground(foreground) }())
        #expect(workspace.currentForeground == foreground)
        #expect({ workspace.popForeground() }())
        #expect(workspace.currentForeground == nil)
        #expect({ !workspace.popForeground() }())
        #expect(region[0] == 0xA5)
        #expect(region[StaticSignalAnalyzerNRFLayoutWorkspace.publishedMarkerOffset] == 1)
        workspace.reset()
        #expect(!workspace.isActive)
        #expect(region[0] == 0xA5)
        #expect(region[StaticSignalAnalyzerNRFLayoutWorkspace.publishedMarkerOffset] == 1)
        #expect({ workspace.acquire() }())
        #expect({ workspace.visitSemanticScope(at: 0) == .first }())
        workspace.reset()
    }
}

@Test func staticNRFRenderWorkspaceRejectsShortRegion() {
    let preset = GeneratedSignalAnalyzerPresets.nrf52840Static()
    var storage = [UInt8](repeating: 0, count: 4_703)
    storage.withUnsafeMutableBytes { region in
        #expect(
            StaticSignalAnalyzerNRFRenderWorkspace(
                region: region, capacity: preset.runtimeLimits.render,
                structuralCapacity: preset.runtimeLimits.renderWorkspace
            ) == nil)
    }
}
