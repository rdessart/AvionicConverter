//
//  AvionicConverterTests.swift
//  AvionicConverterTests
//
//  Created by Romain DESSART on 20/10/2025.
//

import Testing
@testable import AvionicConverter

struct BnrGroundSpeedTest
{
    let speedConverter = BnrConverter.CreateFromResolution(resolution: 0.125, dataBitLength: 15, offset: 5)

    @Test func Decode() async throws {
        let dataIn: UInt64 = 0x60_0F_01
        let result = speedConverter.decode(data: AvionicData(value: dataIn))
        #expect(result.value == 15.0)
    }
    
    @Test func EncodeFailure() async throws {
        #expect(speedConverter.encode(value: 15.0, status: .FailureWarning).avionicValue == 0x00_0F_00)
    }
    
    @Test func EncodeNoData() async throws {
        #expect(speedConverter.encode(value: 15.0, status: .NoComputedData).avionicValue == 0x20_0F_00)
    }
    
    @Test func EncodeFunctionalTest() async throws {
        #expect(speedConverter.encode(value: 15.0, status: .FunctionalTest).avionicValue == 0x40_0F_00)
    }
    
    @Test func EncodeOk() async throws {
        #expect(speedConverter.encode(value: 15.0, status: .NormalOps).avionicValue == 0x60_0F_00)
    }
}
