
public class BnrConverter: IConverter, Hashable
{
    public static func == (lhs: BnrConverter, rhs: BnrConverter) -> Bool {
        return lhs.resolution == rhs.resolution
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(resolution)
    }
    
    public var range: Double?
    public var resolution: Double?
    public var dataBitLength: UInt16
    public var offset: UInt16
    public var isSigned: Bool
    public var maxValue: UInt64
    public var converterType: ConverterType = .bnr
    public var bnrType: BnrConverterType

    public static func CreateFromRange(range: Double, dataBitLength: UInt16, offset: UInt16, isSigned: Bool) -> BnrConverter
    {
        let maxValue: UInt64 = isSigned ? (1 << (dataBitLength - 1)) - 1 : (1 << dataBitLength) - 1
        let resolution: Double = range / Double(maxValue)
        return BnrConverter(resolution: resolution, dataBitLength: dataBitLength,offset: offset,maxValue: maxValue,range: range,signed: isSigned)
    }
    
    public static func CreateEmpty() -> BnrConverter
    {
        return BnrConverter(resolution: 1, dataBitLength: 20,offset: 0,maxValue: 0,range: 180.0,signed: false)
    }

    public static func CreateFromResolution(resolution: Double, dataBitLength: UInt16, offset: UInt16) -> BnrConverter
    {
        let max: UInt64 = (1 << dataBitLength) - 1
        return BnrConverter(resolution: resolution, dataBitLength: dataBitLength, offset: offset, maxValue: max)
    }

    public func decode(data: AvionicData) -> AvionicResult
    {
        let raw: UInt64 = data.avionicValue.GetBits(length: dataBitLength, offset: offset)
        let bnrValue: UInt64 = data.avionicValue.GetBits(length:2,offset: 21)
        let status: BnrStatusMatrix = BnrStatusMatrix(rawValue: bnrValue)!
        return AvionicResult(value: Double(raw) * resolution!,status: status)
    }

    public func encode(value: Double, status: BnrStatusMatrix, source: AvionicSource? = (nil as AvionicSource?)) -> AvionicData
    {
        var raw: UInt64 = UInt64(value / resolution!) << offset
        raw |= UInt64(status.rawValue) << (dataBitLength + offset + 1)
        let res = AvionicData(value: raw,source: source)
        return res
    }

    private init(resolution: Double, dataBitLength: UInt16, offset: UInt16, maxValue: UInt64, signed: Bool = false)
    {
        self.bnrType = .range
        self.resolution = resolution
        self.dataBitLength = dataBitLength
        self.offset = offset
        self.isSigned = signed
        self.maxValue = maxValue
    }

    private init(resolution: Double, dataBitLength: UInt16, offset: UInt16, maxValue: UInt64,range: Double, signed: Bool = false)
    {
        self.bnrType = .resolution
        self.resolution = resolution
        self.dataBitLength = dataBitLength
        self.offset = offset
        self.isSigned = signed
        self.maxValue = maxValue
        self.range = range
    }
}
