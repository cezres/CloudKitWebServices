//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/6/29.
//

import Foundation

public struct CKFetchRecordsRequest: CKDatabaseRequest {
    public static var subpath: String = "records/lookup"
    
    public typealias Response = [CKRecordResult]

    public var recordIds: [CKRecordID]
    
    public var desiredKeys: [CKRecordFieldKey]?

    public var zoneID: CKRecordZone?
}

extension CKFetchRecordsRequest {
    enum CodingKeys: String, CodingKey {
        case records
        case zoneID
        case desiredKeys
        case numbersAsStrings
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recordIds.map { ["recordName": $0] }, forKey: .records)
        if let zoneID = zoneID {
            try container.encode(zoneID, forKey: .zoneID)
        }
        if let desiredKeys = desiredKeys {
            try container.encode(desiredKeys, forKey: .desiredKeys)
        }
    }
}

extension CKFetchRecordsRequest {
    public static func decodeResponse(_ data: Data) throws -> [CKRecordResult] {
        struct CKFetchRecordsResponse: Decodable {
            let records: [CKRecordResult]
        }
        return try decodeResponse(data, type: CKFetchRecordsResponse.self).records
    }
}
