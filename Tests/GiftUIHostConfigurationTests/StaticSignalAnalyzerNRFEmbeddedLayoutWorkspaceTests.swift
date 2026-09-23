import GiftUI
import GiftUILayout
import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFEmbeddedLayoutWorkspaceMatchesHostScopeRecords() {
    var targetScopeBytes = [UInt8](repeating: 0, count: 3_136)
    var targetTextBytes = [UInt8](repeating: 0, count: 4_704)
    var hostScopeBytes = [UInt8](repeating: 0, count: 3_136)
    var hostTextBytes = [UInt8](repeating: 0, count: 4_704)
    targetScopeBytes.withUnsafeMutableBytes { targetScopes in
        targetTextBytes.withUnsafeMutableBytes { targetText in
            hostScopeBytes.withUnsafeMutableBytes { hostScopes in
                hostTextBytes.withUnsafeMutableBytes { hostText in
                    guard
                        var target = StaticSignalAnalyzerNRFEmbeddedLayoutWorkspace(
                            scopes: targetScopes, text: targetText
                        ),
                        var host = StaticSignalAnalyzerNRFLayoutWorkspace(
                            scopes: hostScopes, text: hostText
                        )
                    else {
                        Issue.record("Exact layout regions must construct")
                        return
                    }
                    let targetAcquired = target.acquire()
                    let hostAcquired = host.acquireLayout()
                    #expect(targetAcquired && hostAcquired)
                    let duplicateAcquire = target.acquire()
                    #expect(!duplicateAcquire)
                    let first = LayoutMeasurement(
                        idealSize: Size(width: 480, height: 320)!,
                        resolvedSize: Size(width: 480, height: 320)!
                    )
                    let targetAppended = target.appendScope(
                        identity: 0xA001,
                        idealWidth: 480, idealHeight: 320,
                        width: 480, height: 320
                    )
                    let hostAppended = host.appendScope(identity: 0xA001, measurement: first)
                    #expect(targetAppended && hostAppended)
                    #expect(target.scopeOrdinal(of: 0xA001) == 0)
                    let duplicateScope = target.appendScope(
                        identity: 0xA001,
                        idealWidth: 1, idealHeight: 1, width: 1, height: 1
                    )
                    #expect(!duplicateScope)
                    #expect([UInt8](targetScopes) == [UInt8](hostScopes))
                    let revised = LayoutMeasurement(
                        idealSize: Size(width: 470, height: 310)!,
                        resolvedSize: first.resolvedSize
                    )
                    let targetReplaced = target.replaceMeasurement(
                        identity: 0xA001,
                        idealWidth: 470, idealHeight: 310,
                        width: 480, height: 320
                    )
                    let hostReplaced = host.storeMeasurement(revised, for: 0xA001)
                    #expect(targetReplaced && hostReplaced)
                    #expect([UInt8](targetScopes) == [UInt8](hostScopes))
                    let placement = LayoutPlacement(
                        bounds: Rect(
                            origin: Point(x: 0, y: 0),
                            size: first.resolvedSize
                        )!,
                        clip: Rect(
                            origin: Point(x: 0, y: 0),
                            size: first.resolvedSize
                        )!
                    )
                    let targetPlaced = target.placeScope(
                        identity: 0xA001,
                        originX: 0, originY: 0, width: 480, height: 320,
                        clipX: 0, clipY: 0, clipWidth: 480, clipHeight: 320
                    )
                    let hostPlaced = host.storePlacement(placement, for: 0xA001)
                    #expect(targetPlaced && hostPlaced)
                    #expect([UInt8](targetScopes) == [UInt8](hostScopes))
                    let targetPushed = target.pushScope(0xA001)
                    let hostPushed = host.pushScope(0xA001)
                    #expect(targetPushed && hostPushed)
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    target.popScope()
                    host.popScope()
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    target.reset()
                    host.resetLayout()
                    #expect([UInt8](targetScopes) == [UInt8](hostScopes))
                    #expect([UInt8](targetText) == [UInt8](hostText))
                    let reacquired = target.acquire()
                    #expect(reacquired)
                }
            }
        }
    }
}
