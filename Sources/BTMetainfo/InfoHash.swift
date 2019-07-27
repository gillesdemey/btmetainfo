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

import Foundation

/// Represents a BitTorrent infohash.
public struct InfoHash {
    /// The minimum InfoHash value
    public static let min = InfoHash(data: Data(count: 20))!
    /// The maximum InfoHash value
    public static var max: InfoHash {
        let bytes: [UInt8] = [
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
        ]
        return InfoHash(data: Data(bytes: bytes, count: 20))!
    }

    /// The InfoHash value in bytes
    public let value: Data

    /// Failable initializer with a hexadecimal string.
    public init?(value: String) {
        guard value.utf8.count == 40 else {
            return nil
        }
        if let data = Data(fromHexEncodedString: value) {
            self.value = data
            return
        }
        return nil
    }

    /// Failable initializer with an expected 20 byte Data value.
    public init?(data: Data) {
        guard data.count == 20 else {
            return nil
        }
        self.value = data
    }

    /// Finds a random InfoHash value in a Range.
    public static func random(in range: Range<InfoHash>) -> InfoHash {
        let dataBitDiff = range.upperBound.difference(from: range.lowerBound)
        let (randomData, _) = Data.randomizeUpTo(dataBitDiff, isClosedRange: false).addBits(range.lowerBound.value)
        return InfoHash(data: randomData)!
    }

    /// Finds a random InfoHash value in a ClosedRange.
    public static func random(in range: ClosedRange<InfoHash>) -> InfoHash {
        let dataBitDiff = range.upperBound.difference(from: range.lowerBound)
        let (randomData, _) = Data.randomizeUpTo(dataBitDiff, isClosedRange: true).addBits(range.lowerBound.value)
        return InfoHash(data: randomData)!
    }

    /// Finds the distance between two InfoHash values.
    public func distance(from other: InfoHash) -> InfoHash {
        var data = Data(count: 20)
        for index in 0..<20 {
            data[index] = self.value[index] ^ other.value[index]
        }
        return InfoHash(data: data)!
    }

    private func difference(from other: InfoHash) -> Data {
        var bigger: Data
        var smaller: Data
        if self < other {
            bigger = other.value
            smaller = self.value
        } else {
            bigger = self.value
            smaller = other.value
        }
        let (data, _) = bigger.addBits(smaller.twosComplement())
        return data
    }

    /// Finds the middle value between this InfoHash and another InfoHash.
    public func middle(from other: InfoHash) -> InfoHash {
        var (data, overflow) = self.value.addBits(other.value)
        data = data.shiftBits(by: 1)
        if overflow {
            data[0] |= 0x80
        }

        return InfoHash(data: data)!
    }

    /// Returns the previous InfoHash.
    ///
    /// - Returns: the previous InfoHash in terms of bit values, or an all zero InfoHash if this instance is all zeroes.
    public func prev() -> InfoHash {
        var data = Data(count: 20)
        let offsetFromEnd = self.value.lastIndex { $0 != 0 } ?? self.value.startIndex
        var dataIndex = data.startIndex
        for index in data.startIndex..<offsetFromEnd {
            data[dataIndex] = self.value[index]
            dataIndex = dataIndex.advanced(by: 1)
        }

        data[dataIndex] = self.value[offsetFromEnd] == 0 ? 0xFF : self.value[offsetFromEnd] - 1
        dataIndex = dataIndex.advanced(by: 1)

        for index in offsetFromEnd.advanced(by: 1)..<self.value.endIndex {
            data[index] = 0xFF
            dataIndex = dataIndex.advanced(by: 1)
        }

        return InfoHash(data: data)!
    }
}

extension InfoHash: CustomDebugStringConvertible {
    public var debugDescription: String {
        return value.hexadecimalString
    }
}

extension InfoHash: Equatable {}

extension InfoHash: Hashable {}

extension InfoHash: Comparable {
    public static func < (lhs: InfoHash, rhs: InfoHash) -> Bool {
        for index in 0..<20 {
            if lhs.value[index] == rhs.value[index] {
                continue
            }
            return lhs.value[index] < rhs.value[index]
        }
        return false
    }
}

extension InfoHash: Codable {
    private enum CodingKeys: String, CodingKey {
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stringValue = try container.decode(String.self, forKey: CodingKeys.value)
        guard let dataValue = Data(fromHexEncodedString: stringValue) else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.value],
                debugDescription: "Cannot decode data from \(stringValue)"
            )
            throw DecodingError.dataCorrupted(context)
        }
        self.value = dataValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value.hexadecimalString, forKey: CodingKeys.value)
    }
}

/// NodeID represents a DHT node
public typealias NodeID = InfoHash
