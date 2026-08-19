import Foundation

// Disposable, experiment-local vocabulary. The closed values deliberately do
// not model target or backend identity and are not production API candidates.

enum OperationSet: Equatable { case opaqueMVP }
enum Delivery: Equatable { case synchronousBorrowedOneShot, replayable }
enum PixelEncoding: Int, CaseIterable { case rgb565 = 0, xrgb8888 = 1 }

struct EncodingSet: OptionSet, Equatable {
    let rawValue: UInt8
    static let rgb565 = EncodingSet(rawValue: 1 << 0)
    static let xrgb8888 = EncodingSet(rawValue: 1 << 1)
}

enum ProducedLifetime: Equatable { case offerScoped, owned }
enum AcceptedLifetime: Equatable {
    case synchronousBorrow
    case retainedAsynchronousBorrow
    case copyOnSubmit
}
enum Handoff: Equatable { case synchronous, queued }

struct Extent: Equatable {
    let width: Int
    let height: Int

    var isValid: Bool { width > 0 && height > 0 }
}

struct Requirements: Equatable {
    let operationSet: OperationSet
    let delivery: Delivery
    let extent: Extent
}

struct Producer: Equatable {
    let operationSet: OperationSet
    let delivery: Delivery
    let encodings: EncodingSet
    let lifetime: ProducedLifetime
    let tileBytes: Int
}

struct Display: Equatable {
    let extent: Extent
    let encodings: EncodingSet
    let acceptedLifetime: AcceptedLifetime
    let handoff: Handoff
    let maxInFlight: Int
}

struct WorkspacePolicy: Equatable {
    let rasterBytes: Int
    let stagingBytes: Int
    let maxInFlight: Int
}

enum Contribution: Equatable {
    case requirements(Requirements)
    case producer(Producer)
    case display(Display)
    case workspace(WorkspacePolicy)
}

enum Unavailable: Int, Equatable {
    case malformedContribution
    case duplicateOwner
    case missingOwner
    case incompatibleOperationSet
    case incompatibleDelivery
    case noCommonCanonicalPixelEncoding
    case incompatibleSubmissionLifetime
    case incompatibleExtent
    case insufficientRasterWorkspace
    case insufficientStaging
    case incompatibleInFlightBound
}

struct Effective: Equatable {
    let operationSet: OperationSet
    let delivery: Delivery
    let extent: Extent
    let encoding: PixelEncoding
    let producedLifetime: ProducedLifetime
    let acceptedLifetime: AcceptedLifetime
    let handoff: Handoff
    let tileBytes: Int
    let stagingBytes: Int
    let maxInFlight: Int
}

enum Resolution: Equatable {
    case available(Effective)
    case unavailable(Unavailable)
}

func resolve(_ contributions: [Contribution]) -> Resolution {
    var requirements: Requirements?
    var producer: Producer?
    var display: Display?
    var workspace: WorkspacePolicy?
    var duplicate = false
    var malformed = false

    for contribution in contributions {
        switch contribution {
        case .requirements(let value):
            if requirements != nil { duplicate = true }
            requirements = value
            if !value.extent.isValid { malformed = true }
        case .producer(let value):
            if producer != nil { duplicate = true }
            producer = value
            if value.encodings.isEmpty || value.tileBytes <= 0 { malformed = true }
        case .display(let value):
            if display != nil { duplicate = true }
            display = value
            if !value.extent.isValid || value.encodings.isEmpty || value.maxInFlight <= 0 {
                malformed = true
            }
        case .workspace(let value):
            if workspace != nil { duplicate = true }
            workspace = value
            if value.rasterBytes <= 0 || value.stagingBytes <= 0 || value.maxInFlight <= 0 {
                malformed = true
            }
        }
    }

    // Validation priority is fixed, so malformed or duplicate inputs cannot
    // become contributor-order-dependent diagnostics.
    if malformed { return .unavailable(.malformedContribution) }
    if duplicate { return .unavailable(.duplicateOwner) }
    guard let requirements, let producer, let display, let workspace else {
        return .unavailable(.missingOwner)
    }
    guard requirements.operationSet == producer.operationSet else {
        return .unavailable(.incompatibleOperationSet)
    }
    guard requirements.delivery == .synchronousBorrowedOneShot,
          producer.delivery == requirements.delivery else {
        return .unavailable(.incompatibleDelivery)
    }

    let intersection = producer.encodings.intersection(display.encodings)
    guard !intersection.isEmpty else {
        return .unavailable(.noCommonCanonicalPixelEncoding)
    }
    let encoding: PixelEncoding = intersection.contains(.rgb565) ? .rgb565 : .xrgb8888

    let lifetimeCompatible: Bool
    switch (producer.lifetime, display.acceptedLifetime) {
    case (_, .copyOnSubmit), (.owned, _), (.offerScoped, .synchronousBorrow):
        lifetimeCompatible = true
    case (.offerScoped, .retainedAsynchronousBorrow):
        lifetimeCompatible = false
    }
    guard lifetimeCompatible else {
        return .unavailable(.incompatibleSubmissionLifetime)
    }
    guard requirements.extent == display.extent else {
        return .unavailable(.incompatibleExtent)
    }
    guard producer.tileBytes <= workspace.rasterBytes else {
        return .unavailable(.insufficientRasterWorkspace)
    }
    guard producer.tileBytes <= workspace.stagingBytes else {
        return .unavailable(.insufficientStaging)
    }
    guard display.maxInFlight <= workspace.maxInFlight else {
        return .unavailable(.incompatibleInFlightBound)
    }

    return .available(Effective(
        operationSet: requirements.operationSet,
        delivery: requirements.delivery,
        extent: requirements.extent,
        encoding: encoding,
        producedLifetime: producer.lifetime,
        acceptedLifetime: display.acceptedLifetime,
        handoff: display.handoff,
        tileBytes: producer.tileBytes,
        stagingBytes: workspace.stagingBytes,
        maxInFlight: display.maxInFlight
    ))
}

struct Rect: Equatable {
    let x: Int
    let y: Int
    let width: Int
    let height: Int

    func contains(x px: Int, y py: Int) -> Bool {
        px >= x && py >= y && px < x + width && py < y + height
    }

    func intersecting(_ other: Rect) -> Rect {
        let left = max(x, other.x)
        let top = max(y, other.y)
        let right = min(x + width, other.x + other.width)
        let bottom = min(y + height, other.y + other.height)
        return Rect(x: left, y: top, width: max(0, right - left), height: max(0, bottom - top))
    }
}

enum RGB565 {
    static let black: UInt16 = 0x0000
    static let blue: UInt16 = 0x001F
    static let red: UInt16 = 0xF800
    static let yellow: UInt16 = 0xFFE0
    static let white: UInt16 = 0xFFFF
}

enum Operation: Equatable {
    case damage(Rect)
    case clear(UInt16)
    case fill(Rect, UInt16)
    case stroke(Rect, UInt16)
    case bitmapText(x: Int, y: Int, color: UInt16)
    case clip(Rect)
}

enum StreamFailure: Error { case secondTraversal, expiredLeaseAccess }

final class LeaseMonitor {
    var active = false
    var traversalCount = 0
    var yieldedOperations = 0
    var expiredAccessAttempts = 0
}

final class Lease {
    let monitor: LeaseMonitor
    init(monitor: LeaseMonitor) { self.monitor = monitor }
}

struct OperationCursor {
    private let operations: [Operation]
    private let lease: Lease
    private var index = 0

    init(operations: [Operation], lease: Lease) {
        self.operations = operations
        self.lease = lease
    }

    mutating func next() throws -> Operation? {
        guard lease.monitor.active else {
            lease.monitor.expiredAccessAttempts += 1
            throw StreamFailure.expiredLeaseAccess
        }
        guard index < operations.count else { return nil }
        defer {
            index += 1
            lease.monitor.yieldedOperations += 1
        }
        return operations[index]
    }
}

final class OneShotOperationSource {
    private let operations: [Operation]
    let monitor = LeaseMonitor()
    private weak var lastLease: Lease?

    init(operations: [Operation]) { self.operations = operations }

    func offer(_ body: (inout OperationCursor) throws -> Void) throws {
        guard monitor.traversalCount == 0 else { throw StreamFailure.secondTraversal }
        monitor.traversalCount += 1
        monitor.active = true
        let lease = Lease(monitor: monitor)
        lastLease = lease
        var cursor = OperationCursor(operations: operations, lease: lease)
        defer { monitor.active = false }
        try body(&cursor)
    }

    var retainedLeaseAfterOffer: Bool { lastLease != nil }
}

final class FakeSynchronousSurface {
    let extent: Extent
    private(set) var pixels: [UInt16]

    init(extent: Extent) {
        self.extent = extent
        pixels = [UInt16](repeating: RGB565.black, count: extent.width * extent.height)
    }

    func submitSpan(x: Int, y: Int, values: ArraySlice<UInt16>) {
        precondition(x >= 0 && y >= 0 && y < extent.height && x + values.count <= extent.width)
        var destination = y * extent.width + x
        for value in values {
            pixels[destination] = value
            destination += 1
        }
    }
}

final class RGB565OneShotTiledPrototype {
    let extent: Extent
    let tileHeight: Int
    private var tileStorage: [UInt16]
    private(set) var tileStorageHighWaterBytes = 0

    init(extent: Extent, tileHeight: Int) {
        precondition(extent.isValid && tileHeight > 0)
        self.extent = extent
        self.tileHeight = tileHeight
        tileStorage = [UInt16](repeating: 0, count: extent.width * tileHeight)
    }

    func consume(_ cursor: inout OperationCursor, surface: FakeSynchronousSurface) throws {
        var damage = Rect(x: 0, y: 0, width: extent.width, height: extent.height)
        var clip = damage
        while let operation = try cursor.next() {
            switch operation {
            case .damage(let rect):
                damage = rect.intersecting(Rect(x: 0, y: 0, width: extent.width, height: extent.height))
                clip = clip.intersecting(damage)
            case .clip(let rect):
                clip = rect.intersecting(damage)
            case .clear(let color):
                rasterize(color: color, damage: damage, clip: clip, surface: surface) { _, _ in true }
            case .fill(let rect, let color):
                rasterize(color: color, damage: damage, clip: clip, surface: surface) { x, y in
                    rect.contains(x: x, y: y)
                }
            case .stroke(let rect, let color):
                rasterize(color: color, damage: damage, clip: clip, surface: surface) { x, y in
                    guard rect.contains(x: x, y: y) else { return false }
                    return x == rect.x || x == rect.x + rect.width - 1 ||
                        y == rect.y || y == rect.y + rect.height - 1
                }
            case .bitmapText(let originX, let originY, let color):
                rasterize(color: color, damage: damage, clip: clip, surface: surface) { x, y in
                    glyphContains(x: x - originX, y: y - originY)
                }
            }
        }
    }

    private func rasterize(
        color: UInt16,
        damage: Rect,
        clip: Rect,
        surface: FakeSynchronousSurface,
        covers: (Int, Int) -> Bool
    ) {
        var tileY = 0
        while tileY < extent.height {
            let rows = min(tileHeight, extent.height - tileY)
            tileStorageHighWaterBytes = max(tileStorageHighWaterBytes, extent.width * rows * 2)
            for localY in 0..<rows {
                let y = tileY + localY
                var x = 0
                while x < extent.width {
                    let isCovered = damage.contains(x: x, y: y) && clip.contains(x: x, y: y) && covers(x, y)
                    if !isCovered {
                        x += 1
                        continue
                    }
                    let start = x
                    while x < extent.width && damage.contains(x: x, y: y) &&
                            clip.contains(x: x, y: y) && covers(x, y) {
                        tileStorage[localY * extent.width + x] = color
                        x += 1
                    }
                    let lower = localY * extent.width + start
                    let upper = localY * extent.width + x
                    // The fake surface copies synchronously. No borrowed tile or
                    // operation data escapes this call.
                    surface.submitSpan(x: start, y: y, values: tileStorage[lower..<upper])
                }
            }
            tileY += rows
        }
    }
}

// Fixed 5 x 5 bitmap for a capital A. Rows are encoded left-to-right in the
// low five bits and are intentionally independent of any font subsystem.
private let glyphRows: [UInt8] = [0b01110, 0b10001, 0b11111, 0b10001, 0b10001]

func glyphContains(x: Int, y: Int) -> Bool {
    guard x >= 0 && x < 5 && y >= 0 && y < glyphRows.count else { return false }
    let bit = UInt8(1 << (4 - x))
    return glyphRows[y] & bit != 0
}

func fixedOperations(extent: Extent, tileHeight: Int) -> [Operation] {
    let full = Rect(x: 0, y: 0, width: extent.width, height: extent.height)
    return [
        .damage(full),
        .clear(RGB565.black),
        .fill(Rect(x: 1, y: 1, width: extent.width - 2, height: extent.height - 2), RGB565.blue),
        .stroke(Rect(x: 0, y: max(0, tileHeight - 1), width: extent.width, height: min(5, extent.height - max(0, tileHeight - 1))), RGB565.white),
        .bitmapText(x: 3, y: max(0, extent.height - 6), color: RGB565.yellow),
        .clip(Rect(x: extent.width - 8, y: 0, width: 8, height: extent.height)),
        .fill(Rect(x: extent.width - 12, y: 3, width: 12, height: min(4, extent.height - 3)), RGB565.red),
    ]
}

// A deliberately simple non-tiled oracle. Its host framebuffer is excluded
// from prototype memory evidence.
func referenceRaster(extent: Extent, operations: [Operation]) -> [UInt16] {
    var pixels = [UInt16](repeating: RGB565.black, count: extent.width * extent.height)
    var damage = Rect(x: 0, y: 0, width: extent.width, height: extent.height)
    var clip = damage

    func paint(color: UInt16, predicate: (Int, Int) -> Bool) {
        for y in 0..<extent.height {
            for x in 0..<extent.width where damage.contains(x: x, y: y) && clip.contains(x: x, y: y) && predicate(x, y) {
                pixels[y * extent.width + x] = color
            }
        }
    }

    for operation in operations {
        switch operation {
        case .damage(let rect):
            damage = rect.intersecting(Rect(x: 0, y: 0, width: extent.width, height: extent.height))
            clip = clip.intersecting(damage)
        case .clip(let rect):
            clip = rect.intersecting(damage)
        case .clear(let color):
            paint(color: color) { _, _ in true }
        case .fill(let rect, let color):
            paint(color: color) { x, y in rect.contains(x: x, y: y) }
        case .stroke(let rect, let color):
            paint(color: color) { x, y in
                rect.contains(x: x, y: y) &&
                    (x == rect.x || x == rect.x + rect.width - 1 || y == rect.y || y == rect.y + rect.height - 1)
            }
        case .bitmapText(let originX, let originY, let color):
            paint(color: color) { x, y in glyphContains(x: x - originX, y: y - originY) }
        }
    }
    return pixels
}

func permutations<T>(_ values: [T]) -> [[T]] {
    if values.count <= 1 { return [values] }
    var result: [[T]] = []
    for index in values.indices {
        var remainder = values
        let head = remainder.remove(at: index)
        for tail in permutations(remainder) { result.append([head] + tail) }
    }
    return result
}

struct Fixture {
    let id: String
    let contributions: [Contribution]
    let expected: Resolution
    let raster: (extent: Extent, tileHeight: Int)?
}

struct Row {
    let id: String
    let expected: String
    let actual: String
    let traversals: Int
    let retainedLease: String
    let tileHighWater: Int
    let imageMatch: String
    let orderIndependent: Bool
}

func stable(_ resolution: Resolution) -> String {
    switch resolution {
    case .available(let value):
        return "available:\(value.encoding == .rgb565 ? "rgb565" : "xrgb8888")"
    case .unavailable(let reason):
        switch reason {
        case .malformedContribution: return "unavailable:malformed-contribution"
        case .duplicateOwner: return "unavailable:duplicate-owner"
        case .missingOwner: return "unavailable:missing-owner"
        case .incompatibleOperationSet: return "unavailable:incompatible-operation-set"
        case .incompatibleDelivery: return "unavailable:incompatible-delivery"
        case .noCommonCanonicalPixelEncoding: return "unavailable:no-common-canonical-pixel-encoding"
        case .incompatibleSubmissionLifetime: return "unavailable:incompatible-submission-lifetime"
        case .incompatibleExtent: return "unavailable:incompatible-extent"
        case .insufficientRasterWorkspace: return "unavailable:insufficient-raster-workspace"
        case .insufficientStaging: return "unavailable:insufficient-staging"
        case .incompatibleInFlightBound: return "unavailable:incompatible-in-flight-bound"
        }
    }
}

func fixture(
    id: String,
    extent: Extent,
    tileHeight: Int,
    displayEncodings: EncodingSet,
    acceptedLifetime: AcceptedLifetime,
    expected: Resolution,
    raster: Bool
) -> Fixture {
    let tileBytes = extent.width * tileHeight * 2
    return Fixture(
        id: id,
        contributions: [
            .requirements(Requirements(operationSet: .opaqueMVP, delivery: .synchronousBorrowedOneShot, extent: extent)),
            .producer(Producer(operationSet: .opaqueMVP, delivery: .synchronousBorrowedOneShot, encodings: .rgb565, lifetime: .offerScoped, tileBytes: tileBytes)),
            .display(Display(extent: extent, encodings: displayEncodings, acceptedLifetime: acceptedLifetime, handoff: .synchronous, maxInFlight: 1)),
            .workspace(WorkspacePolicy(rasterBytes: tileBytes, stagingBytes: 16 * 1024, maxInFlight: 1)),
        ],
        expected: expected,
        raster: raster ? (extent, tileHeight) : nil
    )
}

func expectedAvailable(extent: Extent, tileHeight: Int, acceptedLifetime: AcceptedLifetime) -> Resolution {
    .available(Effective(
        operationSet: .opaqueMVP,
        delivery: .synchronousBorrowedOneShot,
        extent: extent,
        encoding: .rgb565,
        producedLifetime: .offerScoped,
        acceptedLifetime: acceptedLifetime,
        handoff: .synchronous,
        tileBytes: extent.width * tileHeight * 2,
        stagingBytes: 16 * 1024,
        maxInFlight: 1
    ))
}

func writePixels(_ pixels: [UInt16], to url: URL) throws {
    var data = Data(capacity: pixels.count * 2)
    for pixel in pixels {
        data.append(UInt8(pixel & 0xFF))
        data.append(UInt8(pixel >> 8))
    }
    try data.write(to: url)
}

func require(_ condition: @autoclosure () -> Bool, _ message: String) throws {
    if !condition() {
        throw NSError(domain: "SPIKE-001", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

func run(outputDirectory: URL) throws {
    let piExtent = Extent(width: 240, height: 240)
    let nrfExtent = Extent(width: 480, height: 320)
    let piExpected = expectedAvailable(extent: piExtent, tileHeight: 16, acceptedLifetime: .synchronousBorrow)
    let nrfExpected = expectedAvailable(extent: nrfExtent, tileHeight: 4, acceptedLifetime: .synchronousBorrow)
    let fixtures = [
        fixture(id: "TILED-PI-POS", extent: piExtent, tileHeight: 16, displayEncodings: [.rgb565, .xrgb8888], acceptedLifetime: .synchronousBorrow, expected: piExpected, raster: true),
        fixture(id: "TILED-NRF-POS", extent: nrfExtent, tileHeight: 4, displayEncodings: .rgb565, acceptedLifetime: .synchronousBorrow, expected: nrfExpected, raster: true),
        fixture(id: "ENCODING-NEG", extent: nrfExtent, tileHeight: 4, displayEncodings: .xrgb8888, acceptedLifetime: .synchronousBorrow, expected: .unavailable(.noCommonCanonicalPixelEncoding), raster: false),
        fixture(id: "LIFETIME-NEG", extent: nrfExtent, tileHeight: 4, displayEncodings: .rgb565, acceptedLifetime: .retainedAsynchronousBorrow, expected: .unavailable(.incompatibleSubmissionLifetime), raster: false),
        fixture(id: "ENCODING-CONTROL", extent: nrfExtent, tileHeight: 4, displayEncodings: .rgb565, acceptedLifetime: .synchronousBorrow, expected: nrfExpected, raster: false),
        fixture(id: "LIFETIME-CONTROL", extent: nrfExtent, tileHeight: 4, displayEncodings: .rgb565, acceptedLifetime: .synchronousBorrow, expected: nrfExpected, raster: false),
    ]

    // Additional deterministic rejection checks required by the resolver
    // contract but intentionally kept out of the six evidence rows.
    let canonical = fixtures[1].contributions
    try require(resolve(Array(canonical.dropLast())) == .unavailable(.missingOwner), "missing owner was not rejected")
    try require(resolve(canonical + [canonical[0]]) == .unavailable(.duplicateOwner), "duplicate owner was not rejected")
    var malformed = canonical
    malformed[3] = .workspace(WorkspacePolicy(rasterBytes: -1, stagingBytes: 16 * 1024, maxInFlight: 1))
    try require(resolve(malformed) == .unavailable(.malformedContribution), "malformed contribution was not rejected")
    for order in permutations(canonical + [canonical[0]]) {
        try require(resolve(order) == .unavailable(.duplicateOwner), "duplicate diagnostic changed with order")
    }

    // Prove that the source's guards detect both forbidden behaviors. These
    // isolated negative checks do not affect the positive fixture counters.
    let traversalGuardSource = OneShotOperationSource(operations: [.clear(RGB565.black)])
    try traversalGuardSource.offer { cursor in while try cursor.next() != nil {} }
    do {
        try traversalGuardSource.offer { _ in }
        try require(false, "second traversal was accepted")
    } catch StreamFailure.secondTraversal {
        // Expected.
    }

    let leaseGuardSource = OneShotOperationSource(operations: [.clear(RGB565.black)])
    var escapedCursor: OperationCursor?
    try leaseGuardSource.offer { cursor in escapedCursor = cursor }
    do {
        _ = try escapedCursor?.next()
        try require(false, "expired lease access was accepted")
    } catch StreamFailure.expiredLeaseAccess {
        // Expected.
    }
    try require(leaseGuardSource.monitor.expiredAccessAttempts == 1, "expired lease access was not observed")
    escapedCursor = nil
    try require(!leaseGuardSource.retainedLeaseAfterOffer, "escaped test cursor was not released")

    try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
    var rows: [Row] = []

    for item in fixtures {
        let results = permutations(item.contributions).map(resolve)
        let actual = results[0]
        let orderIndependent = results.allSatisfy { $0 == actual }
        try require(orderIndependent, "\(item.id) changed with contributor order")
        try require(actual == item.expected, "\(item.id) expected \(stable(item.expected)), got \(stable(actual))")

        var traversals = 0
        var retainedLease = "n/a"
        var tileHighWater = 0
        var imageMatch = "n/a"
        if let raster = item.raster {
            let operations = fixedOperations(extent: raster.extent, tileHeight: raster.tileHeight)
            let source = OneShotOperationSource(operations: operations)
            let surface = FakeSynchronousSurface(extent: raster.extent)
            let prototype = RGB565OneShotTiledPrototype(extent: raster.extent, tileHeight: raster.tileHeight)
            try source.offer { cursor in try prototype.consume(&cursor, surface: surface) }
            let expectedPixels = referenceRaster(extent: raster.extent, operations: operations)
            traversals = source.monitor.traversalCount
            retainedLease = source.retainedLeaseAfterOffer ? "retained" : "none"
            tileHighWater = prototype.tileStorageHighWaterBytes
            imageMatch = surface.pixels == expectedPixels ? "match" : "mismatch"

            try require(traversals == 1, "\(item.id) traversed \(traversals) times")
            try require(source.monitor.yieldedOperations == operations.count, "\(item.id) did not consume the complete stream")
            try require(source.monitor.expiredAccessAttempts == 0, "\(item.id) accessed an expired lease")
            try require(!source.retainedLeaseAfterOffer, "\(item.id) retained the borrowed lease")
            try require(tileHighWater == raster.extent.width * raster.tileHeight * 2, "\(item.id) unexpected tile high-water")
            try require(tileHighWater <= 16 * 1024, "\(item.id) exceeded staging bound")
            try require(surface.pixels == expectedPixels, "\(item.id) differed from reference image")

            try writePixels(surface.pixels, to: outputDirectory.appendingPathComponent("\(item.id.lowercased())-actual.rgb565"))
            try writePixels(expectedPixels, to: outputDirectory.appendingPathComponent("\(item.id.lowercased())-reference.rgb565"))
        }

        rows.append(Row(
            id: item.id,
            expected: stable(item.expected),
            actual: stable(actual),
            traversals: traversals,
            retainedLease: retainedLease,
            tileHighWater: tileHighWater,
            imageMatch: imageMatch,
            orderIndependent: orderIndependent
        ))
    }

    var table = "fixture_id\texpected\tactual\tstream_traversals\tretained_lease\ttile_high_water_bytes\timage\torder_independent\n"
    for row in rows {
        table += "\(row.id)\t\(row.expected)\t\(row.actual)\t\(row.traversals)\t\(row.retainedLease)\t\(row.tileHighWater)\t\(row.imageMatch)\t\(row.orderIndependent ? "yes" : "no")\n"
    }
    let tableURL = outputDirectory.appendingPathComponent("results.tsv")
    try table.write(to: tableURL, atomically: true, encoding: .utf8)
    print(table, terminator: "")
}

do {
    let output = CommandLine.arguments.count > 1
        ? URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        : URL(fileURLWithPath: ".build/spikes/spike-001/results", isDirectory: true)
    try run(outputDirectory: output)
} catch {
    FileHandle.standardError.write(Data("SPIKE-001 FAILED: \(error.localizedDescription)\n".utf8))
    exit(1)
}
