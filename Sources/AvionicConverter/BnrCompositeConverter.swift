//
//  BnrCompositeConverter.swift
//  eSkyBriefer
//
//  Created by Romain DESSART on 17/10/2025.
//

import Foundation
import Collections

public class BnrCompositeConverter: IConverter {
    var converterType: ConverterType = .composite
    
    enum BnrCompositeError: Error {
        case nilArgumentError
        case sourceNotFoundError
    }
    
    public func decode(data: AvionicData) -> AvionicResult
    {
        guard valuesMap.keys.contains(data.source!) else {
            return AvionicResult(value: 0.0, status: .FailureWarning)
        }
        valuesMap[data.source!] = convertersMap[data.source!]!.decode(data: data)
        var result: Double = 0.0
        var atLeastOneStatusOk : Bool = false
        for(_, value) in valuesMap{
            switch value.status {
            case .NormalOps:
                result += value.value
                atLeastOneStatusOk = true
            default:
                continue
            }
        }
        return AvionicResult(value: result, status: atLeastOneStatusOk ? .NormalOps : .NoComputedData)
    }
    
    
    public func encode(value: Double, status: BnrStatusMatrix, source: AvionicSource?) -> AvionicData
    {
        guard source != nil, convertersMap.keys.contains(source!)  else {
            return AvionicData(value: 0, source: source)
        }
        
        
        let scaledValue: UInt64 = UInt64(round(value / resolution))
        let converter  = convertersMap[source!]!
        let bitOffset = getHigherOrderBitsTotal(source:source!)
        var avionicValue: UInt64 = scaledValue.GetBits(length: converter.dataBitLength,offset: bitOffset)
        avionicValue <<= converter.offset
        if converter.isSigned && value < 0.0 {
            avionicValue |= 1 << (converter.offset + converter.dataBitLength)
        }
        if converter.dataBitLength < 20 {
            avionicValue |= 1
        }
        
        avionicValue |= UInt64(status.rawValue) << (converter.offset + converter.dataBitLength + 1)
        return AvionicData(value: avionicValue, source: source)
    }
    
    public var resolution: Double = 0.0
    public var orderedSource: OrderedSet<AvionicSource> = []
    public var convertersMap: Dictionary<AvionicSource, BnrConverter> = [:]
    public var valuesMap: Dictionary<AvionicSource, AvionicResult> = [:]

    
    public func AddConverter(source: AvionicSource, converter: BnrConverter, order: Int){
        orderedSource.insert(source, at: order)
        convertersMap[source] = converter
        valuesMap[source] = AvionicResult(value: 0.0, status: .NoComputedData)
        let range: Double? = convertersMap[orderedSource[0]]?.range
        if range == nil{
            if orderedSource.isEmpty {
                resolution = 0.0
            }
            else{
                resolution = convertersMap[orderedSource.last!]!.resolution ?? 0.0
            }
        }
        else{
            var bitsCount: UInt16 = 0
            for(_, converter) in convertersMap{
                bitsCount += converter.dataBitLength
            }
            
            let maxValue = (1 << bitsCount) - 1;
            resolution = range! / Double(maxValue)
        }
    }

    
    public func getHigherOrderBitsTotal(source: AvionicSource) -> UInt16 {
        var offset: UInt16 = 0
        let index: Int = orderedSource.firstIndex(of: source) ?? -1
        if index == -1{
            return 0 
        }
        
        //let currentKey: AvionicSource = orderedSource[index]
        
        for i in (index+1)..<orderedSource.endIndex{
            let key: AvionicSource = orderedSource[i]
            offset += convertersMap[key]!.dataBitLength
        }
        return offset
    }
    
    
}
