//
//  Extensions.swift
//  BigIntCompress
//
//  Created by Þorvaldur Rúnarsson on 07/10/2017.
//

import Foundation

internal extension String {
    internal func getHexByte(startIndex: Int, endIndex: Int) -> UInt8? {
        guard endIndex - startIndex <= 2 else {
            fatalError("Hex string from index \(startIndex) to index \(endIndex) is to big to be represented as a single byte")
        }
        
        let start = self.index(self.startIndex, offsetBy: startIndex)
        let end = self.index(self.startIndex, offsetBy: endIndex)
        
        let hexString = String(self[start..<end])
        
        let scanner = Scanner(string: hexString)
        var value: UInt32 = 0
        
        if scanner.scanHexInt32(&value) {
            return UInt8(value)
        }
        return nil
    }
}
