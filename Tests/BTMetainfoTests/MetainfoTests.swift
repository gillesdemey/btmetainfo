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

import Bencode
import class Foundation.Bundle
@testable import BTMetainfo
import XCTest

internal final class MetainfoTests: XCTestCase {
    var decoder: BencodeDecoder!

    override func setUp() {
        decoder = BencodeDecoder()

        super.setUp()
    }

    func testDecode_UbuntuMetainfo() throws {
        guard #available(macOS 10.13, *) else {
            return
        }

        let torrentFileURL = resourcesDirectory
            .appendingPathComponent("ubuntu-18.04.2-live-server-amd64.iso.torrent")
        let data = try Data(contentsOf: torrentFileURL)
        let metainfo = try decoder.decode(Metainfo.self, from: data)
        XCTAssertEqual("http://torrent.ubuntu.com:6969/announce", metainfo.announce)
        XCTAssertEqual("ubuntu-18.04.2-live-server-amd64.iso", metainfo.info.name)
        XCTAssertEqual(524_288, metainfo.info.pieceLength)
        XCTAssertEqual(33360, metainfo.info.pieces.count)
        XCTAssertEqual(1668, metainfo.info.piecesCount)
        XCTAssertEqual(874_512_384, metainfo.info.length)
        XCTAssertEqual(874_512_384, metainfo.info.pieceLength * metainfo.info.piecesCount)
        XCTAssertEqual("842783e3005495d5d1637f5364b59343c7844707", metainfo.info.infoHash.value.hexadecimalString)
    }

    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("Couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }

    var resourcesDirectory: URL {
        print(productsDirectory)
        return productsDirectory
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Resources")
    }
}
