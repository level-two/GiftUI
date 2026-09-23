import SignalAnalyzerTargetHost
import Testing

@Test func staticNRFILI9486TransportCallsOneRowCABIAndMapsStatus() {
    let accepted: StaticSignalAnalyzerNRFILI9486Write = {
        x, y, width, height, bytes, byteCount in
        x == 479 && y == 319 && width == 1 && height == 1
            && byteCount == 2 && bytes?[0] == 0xAB && bytes?[1] == 0xCD
            ? 0 : -1
    }
    let refused: StaticSignalAnalyzerNRFILI9486Write = {
        _, _, _, _, _, _ in -5
    }
    var transport = StaticSignalAnalyzerNRFILI9486Transport(write: accepted)
    var failingTransport = StaticSignalAnalyzerNRFILI9486Transport(write: refused)
    let pixels: [UInt8] = [0xAB, 0xCD]
    pixels.withUnsafeBytes { bytes in
        let acceptedRun = transport.presentRGB565BigEndian(
            x: 479, y: 319, pixelCount: 1, bytes: bytes
        )
        #expect(acceptedRun)
        let invalidRun = transport.presentRGB565BigEndian(
            x: 479, y: 319, pixelCount: 2, bytes: bytes
        )
        #expect(!invalidRun)
        let failedRun = failingTransport.presentRGB565BigEndian(
            x: 479, y: 319, pixelCount: 1, bytes: bytes
        )
        #expect(!failedRun)
    }
}
