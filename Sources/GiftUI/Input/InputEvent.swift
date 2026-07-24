public enum InputEvent: Equatable, Sendable {
    case pointerDown(Point)
    case pointerMove(Point)
    case pointerUp(Point)
}
