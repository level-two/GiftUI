import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFPackedSemanticRecordTableFitsExactRegion() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    #expect(table.scopeOffset == StaticSignalAnalyzerNRFSemanticRegionStore.encodedByteCount)
    #expect(
        table.scopeOffset + Int(table.maximumScopeCount) * table.scopeStride == table.scalarOffset)
    #expect(table.scalarOffset + Int(table.maximumScalarCount) * 4 == table.actionOffset)
    #expect(table.actionOffset + Int(table.actionCount) * 2 == table.reservedOffset)
    #expect(table.reservedOffset + 16 == table.regionByteCount)
}

@Test func staticNRFPackedSemanticRecordsRoundTripAtTableBoundaries() {
    var bytes = [UInt8](repeating: 0, count: 3_024)
    bytes.withUnsafeMutableBytes { region in
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        let record = StaticSignalAnalyzerNRFScopeRecord(
            identity: 0xA2B3,
            parent: 96,
            firstChild: table.missingOrdinal,
            nextSibling: table.missingOrdinal,
            kind: .text,
            flags: 0x7F,
            auxiliary: 0xC4D5,
            payload0: 0x1234_5678,
            payload1: 0x90AB_CDEF,
            payload2: 0xFEDC_BA09
        )
        #expect(table.storeScope(record, at: 97, in: region))
        #expect(table.scope(at: 97, in: region) == record)
        #expect(table.storeScalar(0x10_FFFF, at: 138, in: region))
        #expect(table.scalar(at: 138, in: region) == 0x10_FFFF)
        #expect(table.storeActionScope(97, at: 5, in: region))
        #expect(table.actionScope(at: 5, in: region) == 97)
        #expect(table.scope(at: 98, in: region) == nil)
        #expect(table.scalar(at: 139, in: region) == nil)
        #expect(table.actionScope(at: 6, in: region) == nil)
    }
    #expect(bytes[3_008 ..< 3_024].allSatisfy { $0 == 0 })
}

@Test func staticNRFPackedSemanticRecordsRejectInvalidWritesWithoutMutation() {
    var bytes = [UInt8](repeating: 0x5A, count: 3_024)
    bytes.withUnsafeMutableBytes { region in
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        let badRelation = StaticSignalAnalyzerNRFScopeRecord(
            identity: 1,
            parent: 98,
            firstChild: table.missingOrdinal,
            nextSibling: table.missingOrdinal,
            kind: .proxy,
            flags: 0,
            auxiliary: 0,
            payload0: 0,
            payload1: 0,
            payload2: 0
        )
        #expect(!table.storeScope(badRelation, at: 0, in: region))
        #expect(!table.storeScope(badRelation, at: 98, in: region))
        #expect(!table.storeScalar(0xD800, at: 0, in: region))
        #expect(!table.storeScalar(0x11_0000, at: 0, in: region))
        #expect(!table.storeScalar(65, at: 139, in: region))
        #expect(!table.storeActionScope(98, at: 0, in: region))
        #expect(!table.storeActionScope(0, at: 6, in: region))
        let short = UnsafeMutableRawBufferPointer(rebasing: region[..<3_023])
        #expect(!table.storeScalar(65, at: 0, in: short))
        #expect(table.scope(at: 0, in: short) == nil)
    }
    #expect(bytes.allSatisfy { $0 == 0x5A })
}

@Test func staticNRFPackedSemanticTopologyValidatesCompleteLinkedTable() {
    var bytes = makeStaticNRFThreeScopeTable()
    bytes.withUnsafeMutableBytes { region in
        #expect(
            StaticSignalAnalyzerNRFPackedSemanticRecords.validateTopology(
                scopeCount: 3,
                scalarCount: 1,
                in: region
            )
        )
        #expect(
            !StaticSignalAnalyzerNRFPackedSemanticRecords.validateTopology(
                scopeCount: 2,
                scalarCount: 1,
                in: region
            )
        )
        #expect(
            !StaticSignalAnalyzerNRFPackedSemanticRecords.validateTopology(
                scopeCount: 99,
                scalarCount: 1,
                in: region
            )
        )
    }
}

@Test func staticNRFPackedSemanticTopologyRejectsBrokenLinksAndValues() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    let baseline = makeStaticNRFThreeScopeTable()
    for (offset, value) in [
        (table.scopeOffset + table.scopeStride + 0, UInt8(10)), // duplicate identity
        (table.scopeOffset + table.scopeStride + 2, UInt8(2)), // parent cycle
        (table.scopeOffset + table.scopeStride + 6, UInt8(0xFF)), // orphan sibling
        (table.scopeOffset + table.scopeStride * 2 + 2, UInt8(1)), // wrong parent
        (table.scalarOffset + 1, UInt8(0xD8)), // surrogate scalar
        (table.actionOffset, UInt8(3)), // action outside used scopes
    ] {
        var bytes = baseline
        bytes[offset] = value
        bytes.withUnsafeMutableBytes { region in
            #expect(!table.validateTopology(scopeCount: 3, scalarCount: 1, in: region))
        }
    }
    var duplicateLink = baseline
    duplicateLink[table.scopeOffset + 4] = 2
    duplicateLink.withUnsafeMutableBytes { region in
        #expect(!table.validateTopology(scopeCount: 3, scalarCount: 1, in: region))
    }
}

@Test func staticNRFPackedSemanticTableSealRequiresCompleteValidTopology() {
    let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
    var bytes = makeStaticNRFThreeScopeTable()
    bytes.withUnsafeMutableBytes { region in
        #expect(table.tableSummary(in: region) == nil)
        #expect(!table.sealTable(scopeCount: 2, scalarCount: 1, in: region))
        #expect(table.sealTable(scopeCount: 3, scalarCount: 1, in: region))
        #expect(
            table.tableSummary(in: region)
                == StaticSignalAnalyzerNRFPackedTableSummary(
                    scopeCount: 3,
                    scalarCount: 1
                )
        )
        #expect(!table.sealTable(scopeCount: 3, scalarCount: 1, in: region))
        #expect(!table.hasDistinctActionScopes(in: region))
        #expect(!table.hasExactCanvasOccurrences(in: region))
        let fingerprint = table.topologyFingerprint(in: region)
        #expect(fingerprint != nil)
        region[table.scalarOffset] = 66
        #expect(table.topologyFingerprint(in: region) == fingerprint)
        region[table.scalarOffset] = 65
    }
    var badFooter = bytes
    badFooter[table.reservedOffset + 10] = 2
    badFooter.withUnsafeMutableBytes { region in
        #expect(table.tableSummary(in: region) == nil)
    }
    var badScope = bytes
    badScope[table.scopeOffset + table.scopeStride + 2] = 2
    badScope.withUnsafeMutableBytes { region in
        #expect(table.tableSummary(in: region) == nil)
    }
    var badTextRange = bytes
    badTextRange[table.scopeOffset + table.scopeStride + 16] = 140
    badTextRange.withUnsafeMutableBytes { region in
        #expect(table.tableSummary(in: region) == nil)
    }
    var badTextGap = bytes
    badTextGap[table.scopeOffset + table.scopeStride + 12] = 1
    badTextGap.withUnsafeMutableBytes { region in
        #expect(table.tableSummary(in: region) == nil)
    }
    var badModifierPayload = bytes
    badModifierPayload[table.scopeOffset + table.scopeStride * 2 + 8] =
        StaticSignalAnalyzerNRFScopeKind.modifier.rawValue
    badModifierPayload.withUnsafeMutableBytes { region in
        #expect(table.tableSummary(in: region) == nil)
    }
}

private func makeStaticNRFThreeScopeTable() -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: 3_024)
    bytes.withUnsafeMutableBytes { region in
        let table = StaticSignalAnalyzerNRFPackedSemanticRecords.self
        let root = StaticSignalAnalyzerNRFScopeRecord(
            identity: 10,
            parent: table.missingOrdinal,
            firstChild: 1,
            nextSibling: table.missingOrdinal,
            kind: .vStack,
            flags: 0,
            auxiliary: 0,
            payload0: 0,
            payload1: 0,
            payload2: 0
        )
        let first = StaticSignalAnalyzerNRFScopeRecord(
            identity: 20,
            parent: 0,
            firstChild: table.missingOrdinal,
            nextSibling: 2,
            kind: .text,
            flags: 0,
            auxiliary: 0,
            payload0: 0,
            payload1: 1,
            payload2: 0
        )
        let second = StaticSignalAnalyzerNRFScopeRecord(
            identity: 30,
            parent: 0,
            firstChild: table.missingOrdinal,
            nextSibling: table.missingOrdinal,
            kind: .proxy,
            flags: 0,
            auxiliary: 0,
            payload0: 0,
            payload1: 0,
            payload2: 0
        )
        #expect(table.storeScope(root, at: 0, in: region))
        #expect(table.storeScope(first, at: 1, in: region))
        #expect(table.storeScope(second, at: 2, in: region))
        #expect(table.storeScalar(65, at: 0, in: region))
        var action: UInt16 = 0
        while action < table.actionCount {
            #expect(table.storeActionScope(2, at: action, in: region))
            action += 1
        }
    }
    return bytes
}
