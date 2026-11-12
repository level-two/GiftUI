import Foundation
import SwiftParser
import SwiftSyntax

// A source outline, deliberately independent of type checking and platform builds.
// Conditional branches remain visible; synthesized and inherited API is not invented.
struct Symbol: Codable {
    var id: String
    var name: String
    var kind: String
    var access: String
    var signature: String
    var documentation: String
    var file: String
    var line: Int
    var conditions: [String]
    var members: [Symbol]
}

struct Module: Codable {
    var name: String
    var files: Int
    var imports: [String]
    var symbols: [Symbol]
    var warnings: [String]
}

struct Scope {
    var path = ""
    var visible = true
    var implicitPublic = false
    var isEnum = false
    var conditions: [String] = []
    var packageAPI = false
}

final class InterfaceExtractor {
    let root: URL
    var visibility: [String: Bool] = [:]
    var packageTypes = Set<String>()
    var imports = Set<String>()

    init(root: URL) { self.root = root }

    func access(_ node: Syntax) -> String? {
        guard let declaration = node.asProtocol(WithModifiersSyntax.self) else { return nil }
        return declaration.modifiers.first {
            ["public", "open", "internal", "package", "private", "fileprivate"].contains(
                $0.name.text)
                && $0.detail == nil
        }?.name.text
    }

    func visible(_ node: Syntax, in scope: Scope, enumCase: Bool = false) -> Bool {
        guard scope.visible else { return false }
        if let attrs = node.asProtocol(WithAttributesSyntax.self),
            attrs.attributes.description.contains("@_spi")
        {
            return false
        }
        if let access = access(node) { return ["public", "open", "package"].contains(access) }
        return scope.implicitPublic || (scope.isEnum && enumCase)
    }

    func nominal(_ node: Syntax) -> (String, String)? {
        if let n = node.as(StructDeclSyntax.self) { return (n.name.text, "struct") }
        if let n = node.as(ClassDeclSyntax.self) { return (n.name.text, "class") }
        if let n = node.as(ActorDeclSyntax.self) { return (n.name.text, "actor") }
        if let n = node.as(EnumDeclSyntax.self) { return (n.name.text, "enum") }
        if let n = node.as(ProtocolDeclSyntax.self) { return (n.name.text, "protocol") }
        return nil
    }

    func qualified(_ name: String, in scope: Scope) -> String {
        scope.path.isEmpty ? name : "\(scope.path).\(name)"
    }

    // Collect internal types too: an explicitly public member cannot expose its
    // internal enclosing type. Extensions are resolved after all files are read.
    func collect(_ node: Syntax, scope: Scope = Scope()) {
        if let (name, kind) = nominal(node), let group = node.asProtocol(DeclGroupSyntax.self) {
            let path = qualified(name, in: scope)
            let exposed = visible(node, in: scope)
            visibility[path] = exposed
            if scope.packageAPI || access(node) == "package" { packageTypes.insert(path) }
            var inner = Scope(path: path, visible: exposed)
            inner.implicitPublic = kind == "protocol"
            inner.isEnum = kind == "enum"
            inner.packageAPI = packageTypes.contains(path)
            collect(Syntax(group.memberBlock.members), scope: inner)
        } else if node.is(ExtensionDeclSyntax.self) {
            return
        } else if node.is(CodeBlockSyntax.self) {
            return
        } else {
            for child in node.children(viewMode: .sourceAccurate) { collect(child, scope: scope) }
        }
    }

    func documentation(_ node: Syntax) -> String {
        node.leadingTrivia.compactMap { piece -> String? in
            switch piece {
            case .docLineComment(let text):
                return String(text.dropFirst(3)).trimmingCharacters(in: .whitespaces)
            case .docBlockComment(let text):
                return String(text.dropFirst(3).dropLast(2)).trimmingCharacters(
                    in: .whitespacesAndNewlines)
            default: return nil
            }
        }.joined(separator: "\n")
    }

    func interfaceAccessors(_ block: AccessorBlockSyntax) -> AccessorBlockSyntax? {
        switch block.accessors {
        case .getter:
            return AccessorBlockSyntax(
                accessors: .accessors([
                    AccessorDeclSyntax(accessorSpecifier: .keyword(.get))
                ]))
        case .accessors(let accessors):
            let exposed = accessors.filter {
                !["willSet", "didSet"].contains($0.accessorSpecifier.text)
            }.map { accessor in
                var a = accessor
                a.body = nil
                return a
            }
            return exposed.isEmpty
                ? nil
                : AccessorBlockSyntax(
                    accessors: .accessors(AccessorDeclListSyntax(exposed)))
        @unknown default:
            return nil
        }
    }

    func signature(_ node: Syntax) -> String {
        var end = node.endPositionBeforeTrailingTrivia.utf8Offset
        // Child bodies are structural parser nodes, so braces in comments,
        // strings, default arguments, and closure types cannot truncate a header.
        for child in node.children(viewMode: .sourceAccurate) {
            if child.is(MemberBlockSyntax.self) || child.is(CodeBlockSyntax.self) {
                end = min(end, child.positionAfterSkippingLeadingTrivia.utf8Offset)
            }
        }
        if let variable = node.as(VariableDeclSyntax.self) {
            var copy = variable
            copy.bindings = PatternBindingListSyntax(
                variable.bindings.map { binding in
                    var b = binding
                    if b.typeAnnotation != nil { b.initializer = nil }
                    if let block = b.accessorBlock {
                        b.accessorBlock = interfaceAccessors(block)
                    }
                    return b
                })
            return copy.trimmedDescription
        }
        if var subscriptDecl = node.as(SubscriptDeclSyntax.self),
            let block = subscriptDecl.accessorBlock
        {
            subscriptDecl.accessorBlock = interfaceAccessors(block)
            return subscriptDecl.trimmedDescription
        }
        let start = node.positionAfterSkippingLeadingTrivia.utf8Offset
        let bytes = Array(node.trimmedDescription.utf8)
        return String(decoding: bytes.prefix(max(0, end - start)), as: UTF8.self)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func extract(
        _ node: Syntax, file: String, converter: SourceLocationConverter, scope: Scope = Scope()
    ) -> [Symbol] {
        if let conditional = node.as(IfConfigDeclSyntax.self) {
            var result: [Symbol] = []
            var previous: [String] = []
            for clause in conditional.clauses {
                var inner = scope
                let condition = clause.condition?.trimmedDescription
                let excluded = previous.map { "!(\($0))" }
                inner.conditions.append(
                    (excluded + (condition.map { [$0] } ?? [])).joined(separator: " && "))
                if let elements = clause.elements {
                    result += extract(
                        Syntax(elements), file: file, converter: converter, scope: inner)
                }
                if let condition { previous.append(condition) }
            }
            return result
        }
        if let imported = node.as(ImportDeclSyntax.self) {
            if let name = imported.path.first?.name.text { imports.insert(name) }
            return []
        }
        var name: String?
        var kind = ""
        var inner: Scope?
        if let (typeName, typeKind) = nominal(node) {
            guard visible(node, in: scope) else { return [] }
            name = typeName
            kind = typeKind
            inner = Scope(
                path: qualified(typeName, in: scope), visible: true,
                implicitPublic: kind == "protocol", isEnum: kind == "enum",
                conditions: scope.conditions,
                packageAPI: scope.packageAPI || access(node) == "package")
        } else if let ext = node.as(ExtensionDeclSyntax.self) {
            let type = ext.extendedType.trimmedDescription
            guard scope.visible, visibility[type] ?? true,
                !["private", "fileprivate", "internal"].contains(access(node) ?? "")
            else { return [] }
            name = type
            kind = "extension"
            inner = Scope(
                path: type, visible: true,
                implicitPublic: ["public", "package"].contains(access(node) ?? ""),
                conditions: scope.conditions,
                packageAPI: packageTypes.contains(type) || access(node) == "package")
        } else if let function = node.as(FunctionDeclSyntax.self) {
            name = function.name.text
            kind = "func"
        } else if node.is(InitializerDeclSyntax.self) {
            name = "init"
            kind = "init"
        } else if let variable = node.as(VariableDeclSyntax.self) {
            name = variable.bindings.map { $0.pattern.trimmedDescription }.joined(separator: ", ")
            kind = variable.bindingSpecifier.text
        } else if let alias = node.as(TypeAliasDeclSyntax.self) {
            name = alias.name.text
            kind = "typealias"
        } else if let associated = node.as(AssociatedTypeDeclSyntax.self) {
            name = associated.name.text
            kind = "associatedtype"
        } else if let enumCase = node.as(EnumCaseDeclSyntax.self) {
            name = enumCase.elements.map { $0.name.text }.joined(separator: ", ")
            kind = "case"
        } else if node.is(SubscriptDeclSyntax.self) {
            name = "subscript"
            kind = "subscript"
        } else if let macro = node.as(MacroDeclSyntax.self) {
            name = macro.name.text
            kind = "macro"
        }
        if let name {
            guard inner != nil || visible(node, in: scope, enumCase: kind == "case") else {
                return []
            }
            let members: [Symbol]
            if let inner, let group = node.asProtocol(DeclGroupSyntax.self) {
                members = extract(
                    Syntax(group.memberBlock.members), file: file, converter: converter,
                    scope: inner)
            } else {
                members = []
            }
            if let ext = node.as(ExtensionDeclSyntax.self), members.isEmpty,
                ext.inheritanceClause == nil
            {
                return []
            }
            // Plain conformance extensions may have no explicitly public members.
            // Keep them: the conformance itself is part of the source interface.
            let line = converter.location(for: node.positionAfterSkippingLeadingTrivia).line
            return [
                Symbol(
                    id: "\(file):\(node.positionAfterSkippingLeadingTrivia.utf8Offset)",
                    name: name, kind: kind,
                    access: (scope.packageAPI || access(node) == "package"
                        || inner?.packageAPI == true) ? "package" : "public",
                    signature: signature(node), documentation: documentation(node),
                    file: file, line: line, conditions: scope.conditions, members: members)
            ]
        }
        // Never crawl executable bodies or leak their local declarations.
        if node.is(DeclSyntax.self) || node.is(CodeBlockSyntax.self) { return [] }
        return node.children(viewMode: .sourceAccurate).flatMap {
            extract($0, file: file, converter: converter, scope: scope)
        }
    }

    func module(at directory: URL, excluding exclusions: [String] = []) throws -> Module {
        visibility = [:]
        imports = []
        packageTypes = []
        let files =
            (FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil)?
            .allObjects as? [URL] ?? []).filter { file in
                let relative = String(file.path.dropFirst(directory.path.count + 1))
                return file.pathExtension == "swift"
                    && !exclusions.contains {
                        relative == $0 || relative.hasPrefix($0 + "/")
                    }
            }.sorted {
                $0.path < $1.path
            }
        let parsed = try files.map { file in
            (file, Parser.parse(source: try String(contentsOf: file, encoding: .utf8)))
        }
        for (_, tree) in parsed { collect(Syntax(tree)) }
        var symbols: [Symbol] = []
        var warnings: [String] = []
        for (file, tree) in parsed {
            let relative = String(file.path.dropFirst(root.path.count + 1))
            if tree.hasError {
                warnings.append(
                    "Parser recovery in \(relative); some declarations may be incomplete.")
            }
            symbols += extract(
                Syntax(tree), file: relative,
                converter: SourceLocationConverter(fileName: relative, tree: tree))
        }
        return Module(
            name: directory.lastPathComponent, files: files.count,
            imports: imports.sorted(), symbols: symbols, warnings: warnings)
    }
}

// Read literal target exclusions without evaluating the manifest or invoking
// SwiftPM. The current root manifest uses literal source directory names.
func targetExclusions(_ node: Syntax) -> [String: [String]] {
    var result: [String: [String]] = [:]
    if let call = node.as(FunctionCallExprSyntax.self),
        [".target", ".macro", ".executableTarget"].contains(
            call.calledExpression.trimmedDescription),
        let name = call.arguments.first(where: { $0.label?.text == "name" })?
            .expression.as(StringLiteralExprSyntax.self)?.segments.description,
        let excluded = call.arguments.first(where: { $0.label?.text == "exclude" })?
            .expression.as(ArrayExprSyntax.self)
    {
        result[name] = excluded.elements.compactMap {
            $0.expression.as(StringLiteralExprSyntax.self)?.segments.description
        }
    }
    for child in node.children(viewMode: .sourceAccurate) {
        result.merge(targetExclusions(child)) { first, _ in first }
    }
    return result
}

do {
    let root = URL(fileURLWithPath: CommandLine.arguments[1]).standardizedFileURL
    let sources = root.appendingPathComponent("Sources")
    let directories = try FileManager.default.contentsOfDirectory(
        at: sources, includingPropertiesForKeys: [.isDirectoryKey]
    )
    .filter { try $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true }
    .filter { !$0.lastPathComponent.hasSuffix("Fixture") }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }
    let manifest = root.appendingPathComponent("Package.swift")
    let exclusions: [String: [String]]
    if FileManager.default.fileExists(atPath: manifest.path) {
        exclusions = targetExclusions(
            Syntax(Parser.parse(source: try String(contentsOf: manifest, encoding: .utf8))))
    } else {
        exclusions = [:]
    }
    let extractor = InterfaceExtractor(root: root)
    let modules = try directories.map {
        try extractor.module(at: $0, excluding: exclusions[$0.lastPathComponent] ?? [])
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    FileHandle.standardOutput.write(try encoder.encode(modules))
} catch {
    FileHandle.standardError.write(Data("Interface extraction failed: \(error)\n".utf8))
    exit(1)
}
