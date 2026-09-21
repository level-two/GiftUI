// Generated from the portable Signal Analyzer hierarchy and SPEC-015 workload.
// Keep this output synchronized with the SPEC-001 Static Canvas manifest.

import GiftUIRuntimeCore
import GiftUIRuntimeStatic
import GiftUISemanticCore

package enum StaticSignalAnalyzerNRFSemanticRegionState: UInt8, Equatable, Sendable {
    case candidate = 1
    case published = 2
}

package struct StaticSignalAnalyzerNRFSemanticRegionHeader: Equatable, Sendable {
    package let state: StaticSignalAnalyzerNRFSemanticRegionState
    package let variant: StaticSignalAnalyzerNRFSemanticVariant
    package let rootIdentity: UInt32
    package let expansion: SemanticExpansionSummary
    package let structuralOccurrenceCount: UInt16
    package let recordedTraversalIdentityCount: UInt16
    package let canvasOccurrenceCount: UInt16
    package let revision: UInt32
}

package struct StaticSignalAnalyzerNRFSemanticCanvasDescriptor: Equatable, Sendable {
    package let occurrenceIdentity: UInt16
    package let callableID: UInt16
    package let captureByteCount: UInt16
}

/// Checked fixed records stored directly in the generated 3,024-byte candidate
/// and published regions. The unused tail is deliberately zeroed so later
/// generated primitive records can consume it without changing the ABI.
package enum StaticSignalAnalyzerNRFSemanticRegionStore {
    package static let regionByteCount = 3_024
    package static let encodedByteCount = 88
    package static let canvasDescriptorCount: UInt16 = 5
    package static let actionCodeCount: UInt16 = 6

    private static let magic: UInt32 = 0x5341_4E43
    private static let schemaVersion: UInt16 = 1
    private static let rootIdentity: UInt32 = 1_410_692_621
    private static let revisionOffset = 28
    private static let canvasOffset = 32
    private static let canvasStride = 8
    private static let actionOffset = 72
    private static let checksumOffset = 84

    package static func stageCandidate(
        inputs: inout StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> Bool {
        guard inputs.reserveCandidate(in: &profile) else { return false }
        return profile.withRegion(.semanticCandidate) { region in
            encode(
                inputs: inputs,
                state: .candidate,
                revision: 0,
                into: region
            )
        } == true
    }

    package static func stageCompleteCandidate(
        inputs: inout StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding,
        populate: (UnsafeMutableRawBufferPointer) -> StaticSignalAnalyzerNRFPackedTableSummary?
    ) -> Bool {
        guard inputs.reserveCandidate(in: &profile) else { return false }
        return profile.withRegion(.semanticCandidate) { region in
            let expectedScopes = inputs.semantic.expansion.semanticNodeCount
                .addingReportingOverflow(
                    inputs.semantic.expansion.modifierApplicationCount
                )
            guard encode(inputs: inputs, state: .candidate, revision: 0, into: region),
                let table = populate(region),
                !expectedScopes.overflow,
                table.scopeCount == expectedScopes.partialValue,
                StaticSignalAnalyzerNRFPackedSemanticRecords.sealTable(
                    scopeCount: table.scopeCount,
                    scalarCount: table.scalarCount,
                    in: region
                )
            else { return false }
            store(checksum(of: region), in: region, at: checksumOffset)
            guard let header = decodeHeader(from: region),
                header.state == .candidate,
                header.variant == inputs.semantic.variant,
                header.expansion == inputs.semantic.expansion,
                header.structuralOccurrenceCount
                    == inputs.semantic.structuralOccurrenceCount,
                header.recordedTraversalIdentityCount
                    == inputs.semantic.recordedTraversalIdentityCount,
                header.canvasOccurrenceCount == inputs.semantic.canvasOccurrenceCount,
                StaticSignalAnalyzerNRFPackedSemanticRecords.tableSummary(in: region) == table
            else { return false }
            return true
        } == true
    }

    package static func publishCandidate(
        inputs: borrowing StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        revision: UInt32,
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> Bool {
        publishCandidate(
            inputs: inputs,
            revision: revision,
            requireCompleteTable: false,
            in: &profile
        )
    }

    package static func publishCompleteCandidate(
        inputs: borrowing StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        revision: UInt32,
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> Bool {
        publishCandidate(
            inputs: inputs,
            revision: revision,
            requireCompleteTable: true,
            in: &profile
        )
    }

    private static func publishCandidate(
        inputs: borrowing StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        revision: UInt32,
        requireCompleteTable: Bool,
        in profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> Bool {
        guard revision > 0 else { return false }
        let expected = inputs.semantic
        return profile.withSemanticRegions { candidate, published in
            guard candidate.count == regionByteCount,
                published.count == regionByteCount,
                let header = decodeHeader(from: candidate),
                header.state == .candidate,
                header.variant == expected.variant,
                header.expansion == expected.expansion,
                (!requireCompleteTable
                    || completeTableSummary(in: candidate, header: header) != nil),
                canPublish(revision: revision, in: published)
            else { return false }
            published.baseAddress!.copyMemory(
                from: candidate.baseAddress!,
                byteCount: regionByteCount
            )
            published[6] = StaticSignalAnalyzerNRFSemanticRegionState.published.rawValue
            store(revision, in: published, at: revisionOffset)
            store(checksum(of: published), in: published, at: checksumOffset)
            return true
        } == true
    }

    package static func completeTableSummary(
        in family: RuntimeStorageFamily,
        profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticSignalAnalyzerNRFPackedTableSummary? {
        guard family == .semanticCandidate || family == .semanticPublished else {
            return nil
        }
        return profile.withRegion(family) { region in
            guard let header = decodeHeader(from: region) else { return nil }
            return completeTableSummary(in: region, header: header)
        } ?? nil
    }

    private static func completeTableSummary(
        in region: UnsafeMutableRawBufferPointer,
        header: StaticSignalAnalyzerNRFSemanticRegionHeader
    ) -> StaticSignalAnalyzerNRFPackedTableSummary? {
        let expectedScopes = header.expansion.semanticNodeCount
            .addingReportingOverflow(header.expansion.modifierApplicationCount)
        guard let table = StaticSignalAnalyzerNRFPackedSemanticRecords.tableSummary(in: region),
            !expectedScopes.overflow,
            table.scopeCount == expectedScopes.partialValue
        else { return nil }
        return table
    }

    package static func header(
        in family: RuntimeStorageFamily,
        profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticSignalAnalyzerNRFSemanticRegionHeader? {
        guard family == .semanticCandidate || family == .semanticPublished else {
            return nil
        }
        return profile.withRegion(family) { region in decodeHeader(from: region) } ?? nil
    }

    package static func canvasDescriptor(
        at index: UInt16,
        in family: RuntimeStorageFamily,
        profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> StaticSignalAnalyzerNRFSemanticCanvasDescriptor? {
        guard index < canvasDescriptorCount,
            family == .semanticCandidate || family == .semanticPublished
        else { return nil }
        return profile.withRegion(family) { region in
            guard decodeHeader(from: region) != nil else { return nil }
            let offset = canvasOffset + Int(index) * canvasStride
            return StaticSignalAnalyzerNRFSemanticCanvasDescriptor(
                occurrenceIdentity: loadUInt16(from: region, at: offset),
                callableID: loadUInt16(from: region, at: offset + 2),
                captureByteCount: loadUInt16(from: region, at: offset + 4)
            )
        } ?? nil
    }

    package static func actionCode(
        at index: UInt16,
        in family: RuntimeStorageFamily,
        profile: inout StaticSignalAnalyzerNRFProductionProfileBinding
    ) -> UInt16? {
        guard index < actionCodeCount,
            family == .semanticCandidate || family == .semanticPublished
        else { return nil }
        return profile.withRegion(family) { region in
            guard decodeHeader(from: region) != nil else { return nil }
            return loadUInt16(from: region, at: actionOffset + Int(index) * 2)
        } ?? nil
    }

    private static func encode(
        inputs: borrowing StaticSignalAnalyzerNRFGeneratedPresentationInputs,
        state: StaticSignalAnalyzerNRFSemanticRegionState,
        revision: UInt32,
        into region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        guard region.count == regionByteCount, region.baseAddress != nil else {
            return false
        }
        region.initializeMemory(as: UInt8.self, repeating: 0)
        store(magic, in: region, at: 0)
        store(schemaVersion, in: region, at: 4)
        region[6] = state.rawValue
        region[7] = inputs.semantic.variant.rawValue
        store(rootIdentity, in: region, at: 8)
        store(inputs.semantic.expansion.semanticNodeCount, in: region, at: 12)
        store(inputs.semantic.expansion.bodyEvaluationCount, in: region, at: 14)
        store(inputs.semantic.expansion.modifierApplicationCount, in: region, at: 16)
        store(inputs.semantic.expansion.actionOccurrenceCount, in: region, at: 18)
        store(inputs.semantic.expansion.maximumObservedDepth, in: region, at: 20)
        store(inputs.semantic.structuralOccurrenceCount, in: region, at: 22)
        store(inputs.semantic.recordedTraversalIdentityCount, in: region, at: 24)
        store(inputs.semantic.canvasOccurrenceCount, in: region, at: 26)
        store(revision, in: region, at: revisionOffset)

        var canvasIndex: UInt16 = 0
        while canvasIndex < canvasDescriptorCount {
            guard let canvas = inputs.canvasInput(at: canvasIndex) else { return false }
            let offset = canvasOffset + Int(canvasIndex) * canvasStride
            store(canvas.occurrenceIdentity, in: region, at: offset)
            store(canvas.callableID, in: region, at: offset + 2)
            store(canvas.declaredCaptureByteCount, in: region, at: offset + 4)
            canvasIndex += 1
        }
        var actionIndex: UInt16 = 0
        while actionIndex < actionCodeCount {
            store(actionIndex, in: region, at: actionOffset + Int(actionIndex) * 2)
            actionIndex += 1
        }
        store(checksum(of: region), in: region, at: checksumOffset)
        return decodeHeader(from: region) != nil
    }

    private static func canPublish(
        revision: UInt32,
        in region: UnsafeMutableRawBufferPointer
    ) -> Bool {
        var isEmpty = true
        var index = 0
        while index < encodedByteCount {
            if region[index] != 0 {
                isEmpty = false
                break
            }
            index += 1
        }
        if isEmpty { return true }
        guard let published = decodeHeader(from: region),
            published.state == .published
        else { return false }
        return published.revision < revision
    }

    private static func decodeHeader(
        from region: UnsafeMutableRawBufferPointer
    ) -> StaticSignalAnalyzerNRFSemanticRegionHeader? {
        guard region.count == regionByteCount,
            loadUInt32(from: region, at: 0) == magic,
            loadUInt16(from: region, at: 4) == schemaVersion,
            let state = StaticSignalAnalyzerNRFSemanticRegionState(rawValue: region[6]),
            let variant = StaticSignalAnalyzerNRFSemanticVariant(rawValue: region[7]),
            loadUInt32(from: region, at: 8) == rootIdentity,
            loadUInt32(from: region, at: checksumOffset) == checksum(of: region)
        else { return nil }
        return StaticSignalAnalyzerNRFSemanticRegionHeader(
            state: state,
            variant: variant,
            rootIdentity: rootIdentity,
            expansion: SemanticExpansionSummary(
                semanticNodeCount: loadUInt16(from: region, at: 12),
                bodyEvaluationCount: loadUInt16(from: region, at: 14),
                modifierApplicationCount: loadUInt16(from: region, at: 16),
                actionOccurrenceCount: loadUInt16(from: region, at: 18),
                maximumObservedDepth: loadUInt16(from: region, at: 20)
            ),
            structuralOccurrenceCount: loadUInt16(from: region, at: 22),
            recordedTraversalIdentityCount: loadUInt16(from: region, at: 24),
            canvasOccurrenceCount: loadUInt16(from: region, at: 26),
            revision: loadUInt32(from: region, at: revisionOffset)
        )
    }

    private static func store(
        _ value: UInt16,
        in region: UnsafeMutableRawBufferPointer,
        at offset: Int
    ) {
        region.storeBytes(of: value.littleEndian, toByteOffset: offset, as: UInt16.self)
    }

    private static func store(
        _ value: UInt32,
        in region: UnsafeMutableRawBufferPointer,
        at offset: Int
    ) {
        region.storeBytes(of: value.littleEndian, toByteOffset: offset, as: UInt32.self)
    }

    private static func loadUInt16(
        from region: UnsafeMutableRawBufferPointer,
        at offset: Int
    ) -> UInt16 {
        UInt16(littleEndian: region.baseAddress!.load(fromByteOffset: offset, as: UInt16.self))
    }

    private static func loadUInt32(
        from region: UnsafeMutableRawBufferPointer,
        at offset: Int
    ) -> UInt32 {
        UInt32(littleEndian: region.baseAddress!.load(fromByteOffset: offset, as: UInt32.self))
    }

    private static func checksum(
        of region: UnsafeMutableRawBufferPointer
    ) -> UInt32 {
        var value: UInt32 = 2_166_136_261
        var index = 0
        while index < regionByteCount {
            if index < checksumOffset || index >= checksumOffset + MemoryLayout<UInt32>.size {
                value ^= UInt32(region[index])
                value = value &* 16_777_619
            }
            index += 1
        }
        return value
    }
}
