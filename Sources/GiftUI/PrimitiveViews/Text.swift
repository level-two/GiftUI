public struct TextContent {
    package enum Storage {
        case staticString(StaticString)
        case boundedInteger(Int, suffix: StaticString)
        #if !hasFeature(Embedded)
        case dynamicString(String)
        #endif
    }

    package let storage: Storage

    package init(_ content: StaticString) {
        storage = .staticString(content)
    }

    package init(integer value: Int, suffix: StaticString) {
        storage = .boundedInteger(value, suffix: suffix)
    }

    #if !hasFeature(Embedded)
    package init(dynamic content: String) {
        storage = .dynamicString(content)
    }
    #endif

    package func makeTextRun(color: Color = .white) -> TextRun {
        switch storage {
        case .staticString(let content):
            return TextRun(content, color: color)
        case .boundedInteger(let value, let suffix):
            return TextRun(integer: value, suffix: suffix, color: color)
        #if !hasFeature(Embedded)
        case .dynamicString(let content):
            return TextRun(dynamic: content, color: color)
        #endif
        }
    }
}

public struct Text: View, PrimitiveView {
    package let content: TextContent

    /// Creates text from storage whose size is known in the application
    /// binary. Bounded and resource-backed representations will replace the
    /// current graph conversion in the static runtime.
    public init(_ content: StaticString) {
        self.content = TextContent(content)
    }

    /// Creates allocation-bounded decimal text with a statically stored
    /// suffix. The complete representation is at most the decimal width of an
    /// `Int` plus the suffix's UTF-8 storage.
    public init(integer value: Int, suffix: StaticString = "") {
        content = TextContent(integer: value, suffix: suffix)
    }

    #if !hasFeature(Embedded)
    package init(dynamicContent content: String) {
        self.content = TextContent(dynamic: content)
    }
    #endif

    public func _visit<Visitor: ViewVisitor>(_ visitor: inout Visitor) {
        visitor.visitText(content)
    }
}
