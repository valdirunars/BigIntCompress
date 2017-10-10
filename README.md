<img src="https://travis-ci.org/valdirunars/BigIntCompress.svg?branch=master"/>

# BigIntCompress

An algorithm designed for compressing large collections of elements each having only a few possible values. E.g types representable by an `enum`.

It is inspired by the field of bio-informatics where huge collections are often compressed into various formats without exploiting the fact that their components have very few possible values, e.g. a DNA's nucleotide which has only four, A, C, G & T.

## The Algorithm

```swift
public func encode() -> Data? {
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
```

## How to Use

### Swift Package Manager
```swift
.package(url: "https://github.com/valdirunars/BigIntCompress.git", from: "1.0.0"),
```
### Making your collection `Compressable`

First we must find a big integer type and make it conform to BigIntCompress' `BigIntType` there are many sufficient swift libraries out there. I usually use [BigInt](https://github.com/attaswift/BigInt)

``` swift
extension BigInt: BigIntType {

    public var hexString: String {
        return String(self, radix: 16)
    }

    public init?(hexString: String) {
        self.init(hexString, radix: 16)
    }

    public init<T>(_ value: T) where T : Numeric {
        self.init(value)
    }
}
```

Great! Now we are ready to be `Compressable`. Lets say that we are working with strings where the possible values for each character are A, C, G & T, like in the case of a DNA's nucleotide.

```swift
extension String: Compressable {
    public typealias CompressionNumber = BigInt

    public static var possibleComponents: [Element] {
        return [ "A", "C", "G", "T" ]
    }

    public static func single(_ element: Element) -> String {
        return "\(element)"
    }
}
```

Now `String` has two new properties. A static variable `bic` for decoding and an instance variable with an identical name for encoding.

### Encoding and decoding

```swift
let expected = """
CCAAGGATTTCCAAGGATTTTTCTCCACTGTTCTCCACTGTTCTCCACTGACAACCCTGGCCACGTATTCTCCACTGGCCACGTAACAACCCTGGCCACGTACCAAGGATTTGGACGGCTCCCCAAGGATTTGGACGGCTCCGCCACGTAGCCACGTATTCTCCACTGACAACCCTGACAACCCTGGCCACGTAGGACGGCTCCACAACCCTGCCAAGGATTTTTCTCCACTGGCCACGTATTCTCCACTGGGACGGCTCCGGACGGCTCCCCAAGGATTTGCCACGTATTCTCCACTGGGACGGCTCCGCCACGTAGGACGGCTCCGGACGGCTCCCCAAGGATTTTTCTCCACTGGGACGGCTCCTTCTCCACTGCCAAGGATTTCCAAGGATTTGCCACGTACCAAGGATTTGGACGGCTCCGCCACGTAGCCACGTACCAAGGATTTCCAAGGATTTGGACGGCTCCTTCTCCACTGTTCTCCACTGCCAAGGATTTTTCTCCACTGGGACGGCTCCACAACCCTGGGACGGCTCCACAACCCTGTTCTCCACTGTTCTCCACTGTTCTCCACTGCCAAGGATTTGGACGGCTCCCCAAGGATTTTTCTCCACTGTTCTCCACTGGGACGGCTCCGCCACGTAGGACGGCTCCACAACCCTGTTCTCCACTGGCCACGTAGCCACGTAACAACCCTGGCCACGTAACAACCCTGCCAAGGATTTCCAAGGATTTCCAAGGATTTACAACCCTGGCCACGTAGGACGGCTCCGCCACGTATTCTCCACTGGCCACGTAACAACCCTGGCCACGTAACAACCCTGGCCACGTAGCCACGTAGCCACGTATTCTCCACTGGGACGGCTCCCCAAGGATTTGCCACGTAGGACGGCTCCTTCTCCACTGGGACGGCTCCGCCACGTAACAACCCTGTTCTCCACTGGCCACGTACCAAGGATTTCCAAGGATTTGGACGGCTCCCCAAGG
"""

let compressed = expected.bic.encode()
let back = try! String.bic.decode(compressed!)!

XCTAssert(back == expected)
```

### Performance

```swift
let asciiData: Data! = expected.data(using: .ascii)
XCTAssert(compressed.count * 3 < asciiData.count)
```
