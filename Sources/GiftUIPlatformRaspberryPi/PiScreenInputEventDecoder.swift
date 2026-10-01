import GiftUI

/// Decodes Linux evdev records independently of the file descriptor so the
/// exact device path can also be exercised with recorded input.
package struct PiScreenInputEventDecoder {
    private let transform: PiScreenAspectFitTransform
    private let calibration: PiScreenTouchCalibration
    private var contacts = PiScreenContactDecoder()
    private var rawX: Int32 = 0
    private var rawY: Int32 = 0
    private var touching = false
    private var changed = false

    package init(transform: PiScreenAspectFitTransform, calibration: PiScreenTouchCalibration) {
        self.transform = transform
        self.calibration = calibration
    }

    package mutating func consume(type: UInt16, code: UInt16, value: Int32)
        -> PiScreenContactEvent?
    {
        switch (type, code) {
        case (3, 0):
            rawX = value
            changed = true
        case (3, 1):
            rawY = value
            changed = true
        case (1, 330):
            touching = value != 0
            changed = true
        case (0, 0):
            guard changed else { return nil }
            changed = false
            return contacts.update(
                point: transform.logicalPoint(rawX: rawX, rawY: rawY, calibration: calibration),
                touching: touching)
        default: break
        }
        return nil
    }
}
