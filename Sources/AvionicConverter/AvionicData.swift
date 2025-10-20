public struct AvionicData {
    var avionicValue: UInt64
    let source: AvionicSource?
    let timeStampMs: UInt64

    init(value: UInt64, source: AvionicSource? = nil)
    {
        timeStampMs = 0
        avionicValue = value
        self.source = source
    }
};