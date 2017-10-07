//
//  DecodeError.swift
//  BigIntCompress
//
//  Created by Þorvaldur Rúnarsson on 07/10/2017.
//

import Foundation

enum DecodeError: Error {
    case dataNotLargeIntEncoded
    case noElementReturnedForNumber(Any)
}
