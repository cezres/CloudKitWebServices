//
//  CKModifyRecordsRequest.swift
//  
//
//  Created by 翟泉 on 2022/6/29.
//

import Foundation

struct CKModifyRecordsRequest: CKDatabaseRequest {
    
    static var subpath: String = "records/modify"
    
    typealias Response = RecordsResult
    
    var operations: [CKRecordOperation]
    
    var zoneID: CKRecordZone? = nil
    
    var atomic: Bool? = nil
    
    var desiredKeys: [String]? = nil
        
    init(operations: [CKRecordOperation], zoneID: CKRecordZone? = nil, atomic: Bool? = nil, desiredKeys: [String]? = nil) {
        self.operations = operations
        self.zoneID = zoneID
        self.atomic = atomic
        self.desiredKeys = desiredKeys
    }
    
    init(records: [CKRecord], operationType: CKRecordModifyType, zoneID: CKRecordZone? = nil, atomic: Bool? = nil, desiredKeys: [String]? = nil) {
        self.operations = records.map { .init(operationType: operationType, record: $0) }
        self.zoneID = zoneID
        self.atomic = atomic
        self.desiredKeys = desiredKeys
    }
    
    @discardableResult
    mutating func addOperations(_ records: [CKRecord], type: CKRecordModifyType) -> Self {
        operations += records.map {
            .init(operationType: type, record: $0)
        }
        return self
    }
}

public struct CKCommonRecord: Codable {
    
    public var recordName: String? = nil
    
    public var recordType: String? = nil
    
    public var recordChangeTag: String? = nil
    
    public var fields: [CKRecordFieldKey: CKRecordField] = [:]
}

extension CKModifyRecordsRequest {
    static func decodeResponse(_ data: Data) throws -> RecordsResult {
        struct ModifyRecordsResponse: Decodable {
            let records: RecordsResult
        }
        return try decodeResponse(data, type: ModifyRecordsResponse.self).records
    }
}
