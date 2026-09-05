public struct Attachment: Equatable, Sendable {
    public let slot: UInt16
    public let generation: UInt32
}

public struct AttachmentSink: ~Copyable {
    private let storedAttachment: Attachment

    public init(attachment: Attachment) {
        storedAttachment = attachment
    }

    public var attachment: Attachment {
        storedAttachment
    }

    public consuming func finish() {}
}

public func readThenConsume(_ sink: consuming AttachmentSink) -> Attachment {
    let attachment = sink.attachment
    sink.finish()
    return attachment
}
