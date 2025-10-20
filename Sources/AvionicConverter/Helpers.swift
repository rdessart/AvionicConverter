public extension UInt64 {
    func GetBits(length: UInt16, offset: UInt16 = 0)-> UInt64
    {
        return (self >> offset) & ((1 << length) - 1)
    }
    
    func ClearBits(length: UInt16, offset: UInt16 = 0)-> UInt64
    {
        self & ~(((1 << length) - 1) << offset)
    }
}