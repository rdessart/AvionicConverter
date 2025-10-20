//
//  BnrTrackTest.swift
//  AvionicConverterTests
//
//  Created by Romain DESSART on 20/10/2025.
//

import Testing
@testable import AvionicConverter

struct BnrTrackTest {

    let trackConverter = BnrConverter.CreateFromResolution(resolution: 0.0055, dataBitLength: 15, offset: 5)

    @Test func Decode() async throws
    {
        let dataIn: UInt64 = 0x61_A0_00
        let result = trackConverter.decode(data: AvionicData(value: dataIn))
        let encoded = trackConverter.encode(value: result.value,status: result.status).avionicValue
        print("\(String(encoded, radix: 16, uppercase: true))")
        #expect(dataIn == encoded)
    }

}
