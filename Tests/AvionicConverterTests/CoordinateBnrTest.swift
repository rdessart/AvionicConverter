//
//  CoordinateBnrTest.swift
//  AvionicConverterTests
//
//  Created by Romain DESSART on 20/10/2025.
//

import Testing
@testable import AvionicConverter

struct CoordinateBnrTest {
    let vorLatitude: Double = 51.11861111 //BUN (EB)  VOR LATITUDE
    let vorLongitude: Double = 4.84222222 //BUN (EB) VOR LONGITUDE
    
    let latitudeConverter: BnrCompositeConverter
    let longitudeConverter: BnrCompositeConverter
    
    init()
    {
        latitudeConverter = BnrCompositeConverter()
        latitudeConverter.AddConverter(source: AvionicSource(bus:4, label:110), converter: BnrConverter.CreateFromRange(range: 180, dataBitLength: 20, offset: 0, isSigned: true), order: 0)
        latitudeConverter.AddConverter(source: AvionicSource(bus:4, label:120), converter: BnrConverter.CreateFromRange(range: 0.000172, dataBitLength: 11, offset: 9, isSigned: true), order: 1)
        
        longitudeConverter = BnrCompositeConverter()
        longitudeConverter.AddConverter(source: AvionicSource(bus:4, label:111), converter: BnrConverter.CreateFromRange(range: 180, dataBitLength: 20, offset: 0, isSigned: true), order: 0)
        longitudeConverter.AddConverter(source: AvionicSource(bus:4, label:121), converter: BnrConverter.CreateFromRange(range: 0.000172, dataBitLength: 11, offset: 9, isSigned: true), order: 1)
    }
    
    @Test func encode_coordinate_latitude() async throws {
        let lat1 = latitudeConverter.encode(value: vorLatitude, status: .NormalOps, source: AvionicSource(bus:4, label:110))
        #expect(lat1.avionicValue == 0x648B3B)
        print("4/110: 0x\(String(lat1.avionicValue, radix: 16, uppercase: true))")
    }
    
    @Test func encode_coordinate_latitude_fine() async throws {
        let lat2 = latitudeConverter.encode(value: vorLatitude, status: .NormalOps, source: AvionicSource(bus:4, label:120))
        #expect(lat2.avionicValue == 0x67E401)
        print("4/120: 0x\(String(lat2.avionicValue, radix: 16, uppercase: true))")
    }
    
    @Test func encode_coordinate_longitude() async throws {
        let lon1 = longitudeConverter.encode(value: vorLongitude, status: .NormalOps, source: AvionicSource(bus:4, label:111))
        #expect(lon1.avionicValue == 0x606E2F)
        print("4/111: 0x\(String(lon1.avionicValue, radix: 16, uppercase: true))")
    }
    
    @Test func encode_coordinate_longitude_fine() async throws {
        let lon2 = longitudeConverter.encode(value: vorLongitude, status: .NormalOps, source: AvionicSource(bus:4, label:121))
        #expect(lon2.avionicValue == 0x6FD201)
        print("4/121: 0x\(String(lon2.avionicValue, radix: 16, uppercase: true))")
    }

}
