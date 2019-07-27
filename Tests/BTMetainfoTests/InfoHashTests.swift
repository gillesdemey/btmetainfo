//  Copyright 2019 Bryant Luk
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

@testable import BTMetainfo
import XCTest

internal final class InfoHashTests: XCTestCase {
    func testInit_Normal() throws {
        let value = "deca7a89a1dbdc4b213de1c0d5351e92582f31fb"
        guard let infoHash = InfoHash(value: value) else {
            XCTFail("Could not construct infoHash")
            return
        }
        XCTAssertEqual(value, infoHash.debugDescription)
        let expectedData: [UInt8] = [
            0xDE, 0xCA, 0x7A, 0x89, 0xA1,
            0xDB, 0xDC, 0x4B, 0x21, 0x3D,
            0xE1, 0xC0, 0xD5, 0x35, 0x1E,
            0x92, 0x58, 0x2F, 0x31, 0xFB,
        ]
        XCTAssertEqual(Data(bytes: expectedData, count: expectedData.count), infoHash.value)
    }

    func testInit_Not20Bytes() throws {
        let value = "deca7a89a1dbdc4b213de1c0d5351e92582f31"
        XCTAssertNil(InfoHash(value: value))
    }

    func testInit_Data() throws {
        let expectedData: [UInt8] = [
            0xDE, 0xCA, 0x7A, 0x89, 0xA1,
            0xDB, 0xDC, 0x4B, 0x21, 0x3D,
            0xE1, 0xC0, 0xD5, 0x35, 0x1E,
            0x92, 0x58, 0x2F, 0x31, 0xFB,
        ]
        let infoHash = InfoHash(data: Data(bytes: expectedData, count: expectedData.count))!
        XCTAssertEqual("deca7a89a1dbdc4b213de1c0d5351e92582f31fb", infoHash.value.hexadecimalString)
    }

    func testInit_Comparable() throws {
        let expectedData1: [UInt8] = [
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
        ]
        let infoHash1 = InfoHash(data: Data(bytes: expectedData1, count: expectedData1.count))!

        let expectedData2: [UInt8] = [
            0x11, 0x11, 0x11, 0x11, 0x11,
            0x11, 0x11, 0x11, 0x11, 0x11,
            0x11, 0x11, 0x11, 0x11, 0x11,
            0x11, 0x11, 0x11, 0x11, 0x11,
        ]
        let infoHash2 = InfoHash(data: Data(bytes: expectedData2, count: expectedData2.count))!

        XCTAssertTrue(infoHash1 < infoHash2)
        XCTAssertFalse(infoHash1 > infoHash2)
        XCTAssertFalse(infoHash2 < infoHash1)
        XCTAssertTrue(infoHash2 > infoHash1)
    }

    func testDistance() throws {
        let expectedData1: [UInt8] = [
            0x00, 0x01, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x02,
        ]
        let infoHash1 = InfoHash(data: Data(bytes: expectedData1, count: expectedData1.count))!

        let expectedData2: [UInt8] = [
            0x00, 0x02, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x08,
        ]
        let infoHash2 = InfoHash(data: Data(bytes: expectedData2, count: expectedData2.count))!

        XCTAssertEqual(
            "000300000000000000000000000000000000000a",
            infoHash1.distance(from: infoHash2).value.hexadecimalString
        )
    }

    func testMiddlePoint() throws {
        let expectedData1: [UInt8] = [
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        ]
        let infoHash1 = InfoHash(data: Data(bytes: expectedData1, count: expectedData1.count))!

        let expectedData2: [UInt8] = [
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00,
        ]
        let infoHash2 = InfoHash(data: Data(bytes: expectedData2, count: expectedData2.count))!

        let infoHash3 = infoHash1.middle(from: infoHash2)
        XCTAssertEqual("7fffffffffffffffffffffffffffffffffffffff", infoHash3.value.hexadecimalString)

        XCTAssertEqual(
            "bfffffffffffffffffffffffffffffffffffffff",
            infoHash1.middle(from: infoHash3).value.hexadecimalString
        )

        XCTAssertEqual(
            "3fffffffffffffffffffffffffffffffffffffff",
            infoHash2.middle(from: infoHash3).value.hexadecimalString
        )
    }

    func testPrev() {
        let expectedData1: [UInt8] = [
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        ]
        let infoHash1 = InfoHash(data: Data(bytes: expectedData1, count: expectedData1.count))!

        XCTAssertEqual(
            "fffffffffffffffffffffffffffffffffffffffe",
            infoHash1.prev().value.hexadecimalString
        )

        let expectedData2: [UInt8] = [
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFE, 0x00, 0x00, 0x00, 0x00,
        ]
        let infoHash2 = InfoHash(data: Data(bytes: expectedData2, count: expectedData2.count))!

        XCTAssertEqual(
            "fffffffffffffffffffffffffffffffdffffffff",
            infoHash2.prev().value.hexadecimalString
        )
    }
}
