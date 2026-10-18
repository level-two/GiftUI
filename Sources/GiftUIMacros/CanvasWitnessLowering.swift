import Foundation

/// Host/schema adapter output. IDs describe concrete witness types, never
/// occurrence positions; actual values are supplied by semantic traversal.
func canvasWitnessTable(
    configuration: Configuration, inventory: Inventory, presentationModule: String
) throws -> String {
    guard
        presentationModule.range(of: "^[A-Za-z_][A-Za-z_0-9]*$", options: .regularExpression)
            != nil,
        !inventory.canvases.isEmpty, inventory.canvases.count <= Int(UInt16.max)
    else {
        throw LoweringFailure(
            description: "Canvas table requires a finite nonempty witness inventory")
    }
    let names = inventory.canvases.sorted()
    let domain = configuration.domain
    let values = configuration.module + "CanvasValues"
    let table = configuration.module + "CanvasTable"
    var result =
        "import GiftUI\nimport GiftUIDrawing\nimport \(configuration.module)\nimport \(presentationModule)\n"
    result += "@usableFromInline package enum \(values)<D: \(domain)> {\n"
    for (index, name) in names.enumerated() { result += "case v\(index + 1)(\(name)<D>)\n" }
    result += "}\n@usableFromInline package struct \(table)<D: \(domain)>: CanvasValueTable {\n"
    result +=
        "@usableFromInline package typealias Domain = D\n@usableFromInline package typealias CaptureStorage = \(values)<D>\n"
    result +=
        "@inlinable package init() {}\n@inlinable package var callableCaseCount: UInt16 { \(names.count) }\n"
    result += "@inlinable package func captureByteCount(for id: UInt16) -> UInt16? { switch id {\n"
    for (index, name) in names.enumerated() {
        result += "case \(index + 1): UInt16(exactly: MemoryLayout<\(name)<D>>.stride)\n"
    }
    result += "default: nil } }\n"
    result +=
        "@inlinable package static func caseID(for value: borrowing CaptureStorage) -> UInt16 { switch value {\n"
    for index in names.indices { result += "case .v\(index + 1): \(index + 1)\n" }
    result += "} }\n"
    result +=
        "@inlinable package static func payload<Value: _GiftUISemanticPrimitivePayload>(_ value: borrowing Value) -> CaptureStorage? {\n"
    for (index, name) in names.enumerated() {
        result += """
            if Value.self == \(name)<D>.self {
                return withUnsafePointer(to: value) { pointer in
                    pointer.withMemoryRebound(to: \(name)<D>.self, capacity: 1) { .v\(index + 1)($0.pointee) }
                }
            }

            """
    }
    result += "return nil\n}\n"
    result += """
        @inlinable package mutating func invoke(id: UInt16, captures: borrowing CaptureStorage,
            context: inout GraphicsContext, size: Size, read: borrowing _GiftUIFrameRead<D>) throws(DrawingError) {
            guard id == Self.caseID(for: captures) else { throw .invariantViolation }
            switch captures {

        """
    for index in names.indices {
        result +=
            "case .v\(index + 1)(let value): try value._giftUIInvokeCanvas(context: &context, size: size, read: read)\n"
    }
    result += "}\n}\n}\n"
    return result
}
