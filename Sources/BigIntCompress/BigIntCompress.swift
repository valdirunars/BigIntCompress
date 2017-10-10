import Foundation

fileprivate let sizeOfUInt = MemoryLayout<UInt>.size
fileprivate let sizeOfInt = MemoryLayout<Int>.size

public struct BigIntCompress<Base: Compressable> {

    internal let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    internal init(_ base: Base) {
        self.base = base
    }

    public func encode() -> Data? {
        return base.encode()
    }
}

public struct BigIntDecompress<Base: Compressable> {
    public static func decode(_ data: Data) throws -> Base? {
        return try Base.decode(data)
    }
}

public extension Compressable {

    public var bic: BigIntCompress<Self> { return BigIntCompress(self) }
    public static var bic: BigIntDecompress<Self>.Type { return BigIntDecompress<Self>.self }

    internal func encode() -> Data? {
        var number: CompressionNumber = 0

        for element in self {
            number = number * Self.maxUniqueComponentCount + Self.compressionNumberValue(for: element)
        }

        let string = number.hexString

        let mutableData = NSMutableData()

        var i = 0
        while i < (string.count - 1) {
            if let byte = string.getHexByte(startIndex: i, endIndex: i+2) {
                mutableData.append(Data(repeating: byte, count: 1))
            }
            i += 2
        }
        if string.count % 2 == 1,
            let byte = string.getHexByte(startIndex: string.count-1, endIndex: string.count) {

            mutableData.append(Data(repeating: byte, count: 1))
        }

        let finalData = NSMutableData()

        var count = self.count
        let countData = Data(bytes: &count,
                             count: sizeOfInt)

        finalData.append(countData)
        finalData.append(mutableData as Data)
        return finalData as Data
    }

    internal static func recursiveDecode(number: CompressionNumber, length: Int) throws -> Self {
        guard length > 1 else {
            guard let element = element(for: number) else {
                throw DecodeError.dataNotBigIntCompressed
            }
            return .single(element)
        }

        let prefixInt = number / maxUniqueComponentCount
        let remainder = number % maxUniqueComponentCount
        guard let symbol = element(for: remainder) else {
            throw DecodeError.noElementReturnedForNumber(remainder)
        }

        let prefix = try recursiveDecode(number: prefixInt, length: length - 1)

        return prefix + .single(symbol)
    }

    internal static func decode(_ data: Data) throws -> Self? {
        guard data.isEmpty == false else { return nil }

        let countData = data.prefix(upTo: sizeOfInt)
        let length: Int = countData.withUnsafeBytes { $0.pointee }

        let stringData = data.suffix(from: sizeOfInt)

        var numberString = ""
        for (index, byte) in stringData.enumerated() {
            var value = String(byte, radix: 16)
            if value.count == 1 && index != (stringData.count - 1) {
                value = "0" + value
            }
            numberString += value
        }

        guard let initialNumber = CompressionNumber(hexString: numberString) else {
            throw DecodeError.dataNotBigIntCompressed
        }
        return try recursiveDecode(number: initialNumber, length: length)
    }
}
