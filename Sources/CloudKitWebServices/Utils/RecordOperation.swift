//
//  RecordOperation.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation

public struct RecordOperation: Codable {
    public var operationType: OperationType
    public var record: CommonRecord
    public var desiredKeys: [String]? = nil
    
    public enum OperationType: String, Codable {
        case create
        case update
        case forceUpdate
        case replace
        case forceReplace
        case delete
        case forceDelete
    }
}

public struct CommonRecord: Codable {
    public var recordName: String
    public var recordType: String
    public var recordChangeTag: String? = nil
    public var fields: [RecordFieldKey: RecordField] = [:]
}
