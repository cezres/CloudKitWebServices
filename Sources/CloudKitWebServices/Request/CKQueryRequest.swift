//
//  CKQueryRequest.swift
//  
//
//  Created by 翟泉 on 2022/6/29.
//

import Foundation

public struct CKQueryRequest {
    
    public static let maximumResults = 200
    
    public var query: CKQuery?
    
    public var zoneID: CKRecordZone?
    
    public var resultsLimit: Int
    
    public var continuationMarker: String? = nil
    
    public var desiredKeys: [String]? = nil
    
    public var zoneWide: Bool? = nil
        
    public init(query: CKQuery, zoneID: CKRecordZone? = nil, resultsLimit: Int = CKDataSizeLimits.maximumNumberOfRecordsInResponse, desiredKeys: [String]? = nil, zoneWide: Bool? = nil) {
        self.query = query
        self.zoneID = zoneID
        self.resultsLimit = resultsLimit
        self.continuationMarker = nil
        self.desiredKeys = desiredKeys
        self.zoneWide = zoneWide
    }
    
    public init(cursor: CKQueryCursor, zoneID: CKRecordZone? = nil, resultsLimit: Int = CKDataSizeLimits.maximumNumberOfRecordsInResponse, desiredKeys: [String]? = nil, zoneWide: Bool? = nil) {
        self.query = nil
        self.zoneID = zoneID
        self.resultsLimit = resultsLimit
        self.continuationMarker = cursor
        self.desiredKeys = desiredKeys
        self.zoneWide = zoneWide
    }
}

public struct CKQueryResult: Codable {
    public let matchResults: [CKRecordResult]
    public let queryCursor: CKQueryCursor?
    
    enum CodingKeys: CodingKey {
        case records
        case continuationMarker
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.matchResults = try container.decode([CKRecordResult].self, forKey: .records)
        self.queryCursor = try container.decodeIfPresent(CKQueryCursor.self, forKey: .continuationMarker)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.matchResults, forKey: .records)
        try container.encodeIfPresent(self.queryCursor, forKey: .continuationMarker)
    }
}

extension CKQueryRequest: CKDatabaseRequest {
    public static var subpath: String = "records/query"
    
    public typealias Response = CKQueryResult
}
