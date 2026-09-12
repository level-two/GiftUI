// Generated from Tests/ContractFixtures/SPEC012/static-canvas-manifest.yaml.
// Do not edit independently of that checked manifest.

import GiftUI

@testable import GiftUIDrawing

struct GeneratedStaticCanvasCapture1: Equatable, Sendable {
    let color: Color
    let lineWidth: GeometryScalar
}

struct GeneratedStaticCanvasCapture2: Equatable, Sendable {
    let color: Color
    let verticalOffset: GeometryScalar
    let highLevel: GeometryScalar
}

struct GeneratedStaticCanvasCapture3: Equatable, Sendable {}

struct GeneratedStaticCanvasCaptureStorage: Equatable, Sendable {
    let color: Color
    let firstScalar: GeometryScalar
    let secondScalar: GeometryScalar

    init(_ capture: GeneratedStaticCanvasCapture1) {
        color = capture.color
        firstScalar = capture.lineWidth
        secondScalar = 0
    }

    init(_ capture: GeneratedStaticCanvasCapture2) {
        color = capture.color
        firstScalar = capture.verticalOffset
        secondScalar = capture.highLevel
    }

    init(_: GeneratedStaticCanvasCapture3) {
        color = .black
        firstScalar = 0
        secondScalar = 0
    }
}

struct GeneratedStaticCanvasCallableTable: StaticCanvasCallableTable {
    let callableCaseCount: UInt16 = 3

    func captureByteCount(for id: UInt16) -> UInt16? {
        switch id {
        case 1: 8
        case 2: 12
        case 3: 0
        default: nil
        }
    }

    mutating func invoke(
        id: UInt16,
        captures: borrowing GeneratedStaticCanvasCaptureStorage,
        context: inout GraphicsContext,
        size: Size
    ) throws(DrawingError) {
        switch id {
        case 1:
            let color = captures.color
            let lineWidth = captures.firstScalar
            try context.withPath { context, path throws(DrawingError) in
                try path.move(to: Point(x: 0, y: 0))
                try path.addLine(to: Point(x: size.width, y: 0))
                try context.stroke(
                    path,
                    with: .color(color),
                    lineWidth: lineWidth
                )
            }
        case 2:
            let color = captures.color
            let verticalOffset = captures.firstScalar
            let highLevel = captures.secondScalar
            try context.withPath { context, path throws(DrawingError) in
                try path.move(to: Point(x: 0, y: verticalOffset))
                try path.addLine(to: Point(x: size.width, y: highLevel))
                try context.stroke(
                    path,
                    with: .color(color),
                    lineWidth: 1
                )
            }
        case 3:
            try context.withPath { context, path throws(DrawingError) in
                try path.move(to: Point(x: size.width, y: 0))
                try path.addLine(to: Point(x: size.width, y: size.height))
                try context.stroke(path, with: .color(.white), lineWidth: 1)
            }
        default:
            throw DrawingError.invariantViolation
        }
    }
}
