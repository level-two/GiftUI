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
