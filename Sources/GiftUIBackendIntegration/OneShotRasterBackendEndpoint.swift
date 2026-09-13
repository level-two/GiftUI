import GiftUICapabilities
import GiftUIDisplayCore
import GiftUIExecution
import GiftUIFailureCore
import GiftUIRasterCore
import GiftUIRenderCore
import GiftUISurfaceCore
import GiftUITextResources

package protocol RasterFrameEnvelopeValidator {
    borrowing func accepts(_ provenance: FrameProvenance) -> Bool
}

package protocol RasterOfferSessionSink: RasterFrameSink {
    var isIdleForOffer: Bool { get }

    mutating func reserveFrame(
        descriptor: RasterSurfaceDescriptor,
        payloadCapacityBytes: UInt32,
        regionCapacity: UInt16
    ) -> DisplayReservationResult
    mutating func resolveAfterBody(
        _ result: FrameStreamResult
    ) -> FrameOfferResult
    borrowing func health() -> GiftUIOperationalHealth
}

package struct OneShotRasterBackendEndpoint<
    Sink,
    TextMetrics,
    TextRaster,
    EnvelopeValidator
>: RasterBackendEndpoint
where
    Sink: RasterOfferSessionSink,
    TextMetrics: CanonicalTextMetricsView,
    TextRaster: TextRasterResourceView,
    EnvelopeValidator: RasterFrameEnvelopeValidator
{
    package let effectivePresentation: EffectiveRasterPresentation
    package let descriptor: RasterSurfaceDescriptor
    package let payloadLimits: RasterPayloadLimits
    package let textMetrics: TextMetrics
    package let textRaster: TextRaster
    package let textRasterRealization: RasterRealizationID
    package private(set) var sink: Sink
    package private(set) var bodyCallCount: UInt32 = 0
    package private(set) var reservationCallCount: UInt32 = 0
    package private(set) var lastDisplayError: DisplayTargetError?

    private let envelopeValidator: EnvelopeValidator
    private var offerActive = false

    package init?(
        effectivePresentation: EffectiveRasterPresentation,
        descriptor: RasterSurfaceDescriptor,
        payloadLimits: RasterPayloadLimits,
        textMetrics: consuming TextMetrics,
        textRaster: consuming TextRaster,
        textRasterRealization: RasterRealizationID,
        envelopeValidator: consuming EnvelopeValidator,
        sink: consuming Sink,
        startupFailure: RasterBackendError?
    ) {
        guard startupFailure == nil,
            sink.descriptor == descriptor,
            sink.payloadLimits == payloadLimits,
            Self.configurationMatches(
                effectivePresentation,
                descriptor: descriptor,
                payloadLimits: payloadLimits
            )
        else { return nil }
        self.effectivePresentation = effectivePresentation
        self.descriptor = descriptor
        self.payloadLimits = payloadLimits
        self.textMetrics = textMetrics
        self.textRaster = textRaster
        self.textRasterRealization = textRasterRealization
        self.envelopeValidator = envelopeValidator
        self.sink = sink
    }

    package mutating func offer(
        provenance: FrameProvenance,
        body: (inout Sink) -> FrameStreamResult
    ) -> FrameOfferResult {
        guard !offerActive else { return failed(.contractViolation) }
        guard envelopeValidator.accepts(provenance) else {
            return failed(.invalidEnvelope)
        }
        guard sink.descriptor == descriptor,
            sink.payloadLimits == payloadLimits,
            sink.isIdleForOffer
        else { return failed(.contractViolation) }

        let nextReservationCount = reservationCallCount.addingReportingOverflow(1)
        guard !nextReservationCount.overflow else {
            return failed(.contractViolation)
        }
        reservationCallCount = nextReservationCount.partialValue
        lastDisplayError = nil
        let reservation = sink.reserveFrame(
            descriptor: descriptor,
            payloadCapacityBytes: payloadLimits.maximumPayloadBytes,
            regionCapacity: payloadLimits.maximumRegionsPerPayload
        )
        switch reservation {
        case .backpressured:
            return FrameOfferResult(disposition: .backpressured, failure: nil)!
        case .retryableRefusal:
            return FrameOfferResult(
                disposition: .retryableRefusal,
                failure: nil
            )!
        case .nonRetryableRefusal:
            return FrameOfferResult(
                disposition: .nonRetryableRefusal,
                failure: nil
            )!
        case .failure(let error):
            lastDisplayError = error
            return failed(.contractViolation)
        case .reserved:
            break
        }

        offerActive = true
        defer { offerActive = false }
        let nextBodyCount = bodyCallCount.addingReportingOverflow(1)
        guard !nextBodyCount.overflow else {
            return failed(.contractViolation)
        }
        bodyCallCount = nextBodyCount.partialValue
        let streamResult = body(&sink)
        return sink.resolveAfterBody(streamResult)
    }

    package borrowing func health() -> GiftUIOperationalHealth {
        sink.health()
    }

    private func failed(_ failure: FrameOfferFailure) -> FrameOfferResult {
        FrameOfferResult(disposition: .failed, failure: failure)!
    }

    private static func configurationMatches(
        _ effective: EffectiveRasterPresentation,
        descriptor: RasterSurfaceDescriptor,
        payloadLimits: RasterPayloadLimits
    ) -> Bool {
        effective.extent == descriptor.capabilityExtent
            && effective.regionExtent.width == descriptor.regionWidth
            && effective.regionExtent.height == descriptor.regionHeight
            && effective.rowBytes.rawValue == descriptor.bytesPerRow
            && effective.operationStream == .synchronousBorrowedOneShot
            && effective.encoding == descriptor.encoding
            && effective.realization == descriptor.realization
            && effective.requiredRasterBytes.rawValue
                <= payloadLimits.maximumRasterBytes
            && effective.requiredPayloadBytes.rawValue
                == payloadLimits.maximumPayloadBytes
            && effective.inFlightCount == payloadLimits.maximumInFlightPayloads
            && effective.requiredInFlightBytes.rawValue
                == payloadLimits.maximumInFlightBytes
    }
}
