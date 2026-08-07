/// Allocation-free ADS7846/XPT2046 sample processing shared by host tests and
/// Embedded Swift firmware. XPT2046 uses the same 12-bit sample, pressure,
/// calibration, and pen-event model.
public enum GiftUIInputADS7846 {}

/// XPT2046-facing names for the protocol-compatible processing types. The
/// aliases keep existing ADS7846 clients source-compatible while allowing
/// integrations to name the controller that is actually fitted.
public typealias XPT2046RawSample = ADS7846RawSample
public typealias XPT2046CalibrationSamples = ADS7846CalibrationSamples
public typealias XPT2046CalibrationError = ADS7846CalibrationError
public typealias XPT2046CalibrationResult = ADS7846CalibrationResult
public typealias XPT2046Calibration = ADS7846Calibration
public typealias XPT2046PressureThreshold = ADS7846PressureThreshold
public typealias XPT2046Orientation = ADS7846Orientation
public typealias XPT2046TouchProcessor = ADS7846TouchProcessor
