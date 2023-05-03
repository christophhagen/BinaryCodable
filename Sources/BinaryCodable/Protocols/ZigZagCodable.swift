import Foundation

typealias ZigZagCodable = ZigZagEncodable & ZigZagDecodable

protocol ZigZagEncodable {

    var zigZagEncoded: Data { get }

}

protocol ZigZagDecodable {

    init(fromZigZag data: Data, path: [CodingKey]) throws
}

