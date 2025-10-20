//
//  IConverter.swift
//  eSkyBriefer
//
//  Created by Romain DESSART on 17/10/2025.
//

import Foundation

public enum ConverterType: String, CaseIterable, Identifiable
{
    case none
    case bnr
    case bcd
    case file
    case composite
    public var id: Self { self }
}

public enum BnrConverterType: String, CaseIterable, Identifiable
{
    case range
    case resolution
    public var id: Self { self }
}

protocol IConverter {
    var converterType: ConverterType { get }
    func decode(data: AvionicData) -> AvionicResult
    func encode(value: Double, status: BnrStatusMatrix, source: AvionicSource?) -> AvionicData
}
