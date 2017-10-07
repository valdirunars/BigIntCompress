//
//  Protocols.swift
//  BigIntCompress
//
//  Created by Þorvaldur Rúnarsson on 07/10/2017.
//

import Foundation

public protocol BigIntType {
    var hexString: String { get }
    
    init<T>(_ value: T) where T: Numeric
    init?(hexString: String)
}

public protocol Compressable: Collection where Element: Equatable {
    associatedtype CompressionNumber: BigIntType, BinaryInteger
    
    static var possibleComponents: [Element] { get }
    
    static func single(_ element: Element) -> Self
    static func + (left: Self, right: Self) -> Self
}

extension Compressable {
    
    internal static var maxUniqueComponentCount: CompressionNumber {
        return CompressionNumber(possibleComponents.count)
    }
    
    internal static func compressionNumberValue(for element: Element) -> CompressionNumber {
        guard let index = possibleComponents.index(of: element) else {
            fatalError("Unexpectedly processing element which is not a member in possible components")
        }
        
        return CompressionNumber(index)
    }
    
    internal static func element(for compressionNumber: CompressionNumber) -> Element? {
        var index: UInt64 = 0
        let scanner = Scanner(string: compressionNumber.hexString)
        scanner.scanHexInt64(&index)
        
        return possibleComponents[Int(index)]
    }
}

