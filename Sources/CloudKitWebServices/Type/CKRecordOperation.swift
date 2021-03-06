//
//  CKRecordOperation.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation

public struct CKRecordOperation: Codable {
    
    public var operationType: CKRecordModifyType
    
    public var record: CKRecord
    
    public var desiredKeys: [String]? = nil
}

public enum CKRecordModifyType: String, Codable {
    // Create a new record. This operation fails if a record with the same record name already exists.
    case create
    // Update an existing record. Only the fields you specify are changed.
    case update
    // Update an existing record regardless of conflicts. Creates a record if it doesn’t exist.
    case forceUpdate
    // Replace a record with the specified record. The fields whose values you do not specify are set to null.
    case replace
    // Replace a record with the specified record regardless of conflicts. Creates a record if it doesn’t exist.
    case forceReplace
    // Delete the specified record.
    case delete
    // Delete the specified record regardless of conflicts.
    case forceDelete
}
