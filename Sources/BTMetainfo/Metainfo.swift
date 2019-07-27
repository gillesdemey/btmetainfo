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

import CommonCrypto
import Foundation

import Bencode

/// A torrent file's data.
public struct Metainfo: Codable, Equatable {
    /// The announce URL
    public let announce: String?

    /// The info dictionary
    public let info: Info

    private enum CodingKeys: String, CodingKey {
        case announce
        case info
    }

    public init(from decoder: Decoder) throws {
        let metainfo = try decoder.container(keyedBy: CodingKeys.self)
        announce = try metainfo.decodeIfPresent(String.self, forKey: CodingKeys.announce)
        info = try metainfo.decode(Info.self, forKey: CodingKeys.info)
    }
}

/// The Info dictionary
public struct Info: Codable, Equatable {
    /// The file name for a single file torrent
    public let name: String?

    /// The piece length
    public let pieceLength: Int

    /// The pieces data
    public let pieces: Data

    /// The number of pieces
    public var piecesCount: Int {
        return pieces.count / 20
    }

    /// The number of bytes in a single file
    public let length: Int?

    /// The InfoHash for this info dictionary.
    public let infoHash: InfoHash

    fileprivate enum CodingKeys: String, CodingKey {
        case name
        case pieceLength = "piece length"
        case pieces
        case length
    }

    public init(from decoder: Decoder) throws {
        let info = try decoder.container(keyedBy: CodingKeys.self)
        name = try info.decodeIfPresent(String.self, forKey: CodingKeys.name)
        pieceLength = try info.decode(Int.self, forKey: CodingKeys.pieceLength)
        pieces = try info.decode(Data.self, forKey: CodingKeys.pieces)
        length = try info.decode(Int.self, forKey: CodingKeys.length)

        guard let bdecoder = decoder as? _BencodeDecoder else {
            fatalError("Decoding with wrong decoder.")
        }
        var hash = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
        bdecoder.decodedData.withUnsafeBytes { dataPtr -> Void in
            hash.withUnsafeMutableBytes { hashPtr -> Void in
                guard let baseAddress = hashPtr.baseAddress else {
                    fatalError("Could not get base memory address")
                }
                CC_SHA1(
                    dataPtr.baseAddress,
                    UInt32(bdecoder.decodedData.count),
                    baseAddress.assumingMemoryBound(to: UInt8.self)
                )
            }
        }
        guard let infoHash = InfoHash(data: hash) else {
            fatalError("Could not create infoHash")
        }
        self.infoHash = infoHash
    }

    public func encode(to encoder: Encoder) throws {
        var info = encoder.container(keyedBy: CodingKeys.self)
        try info.encodeIfPresent(length, forKey: CodingKeys.length)
        try info.encodeIfPresent(name, forKey: CodingKeys.name)
        try info.encode(pieceLength, forKey: CodingKeys.pieceLength)
        try info.encode(pieces, forKey: CodingKeys.pieces)
    }
}
