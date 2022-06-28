//
//  RecordResult.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation

public typealias RecordResult = Result<Record, RecordFetchError>
public typealias RecordsResult = [RecordResult]

public struct RecordFetchError: Error, Codable {
    public let recordName: String
    public let reason: String
    public let serverErrorCode: String
}

extension Result: Codable, CustomStringConvertible where Success == Record, Failure == RecordFetchError {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .success(try container.decode(Success.self))
        } catch {
            self = .failure(try container.decode(Failure.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .success(let success):
            var values = encoder.singleValueContainer()
            try values.encode(success)
        case .failure(let failure):
            var values = encoder.singleValueContainer()
            try values.encode(failure)
        }
    }
    
    public var description: String {
        switch self {
        case .success(let success):
            return "\(success)"
        case .failure(let failure):
            return "\(failure)"
        }
    }
}
