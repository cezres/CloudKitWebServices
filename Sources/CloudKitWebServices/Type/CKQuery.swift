//
//  CKQuery.swift
//  
//
//  Created by 翟泉 on 2022/6/27.
//

import Foundation

public typealias CKQueryCursor = String

public struct CKQuery: Codable {
    
    public var recordType: String
    
    public var filterBy: [CKQueryFilter]
    
    public var sortBy: [CKQuerySortDescriptor]
    
    public init(recordType: String, filterBy: [CKQueryFilter] = [], sortBy: [CKQuerySortDescriptor] = []) {
        self.recordType = recordType
        self.filterBy = filterBy
        self.sortBy = sortBy
    }
}

public struct CKQueryFilter: Codable {
    
    public var fieldName: String
    
    public var comparator: CKQueryFilterComparator
    
    public var fieldValue: CKRecordField
    
    public init(_ fieldName: String, _ comparator: CKQueryFilterComparator, _ fieldValue: CKRecordField) {
        self.fieldName = fieldName
        self.comparator = comparator
        self.fieldValue = fieldValue
    }
}

public struct CKQuerySortDescriptor: Codable {
    
    public var fieldName: String
    
    public var ascending: Bool
    
    public init(fieldName: String, ascending: Bool) {
        self.fieldName = fieldName
        self.ascending = ascending
    }
}

public enum CKQueryFilterComparator: String, Codable {
    case EQUALS
    case NOT_EQUALS
    case LESS_THAN
    case LESS_THAN_OR_EQUALS
    case GREATER_THAN
    case GREATER_THAN_OR_EQUALS
    case NEAR
    case CONTAINS_ALL_TOKENS
    case IN
    case NOT_IN
    case CONTAINS_ANY_TOKENS
    case LIST_CONTAINS
    case NOT_LIST_CONTAINS
    case NOT_LIST_CONTAINS_ANY
    case BEGINS_WITH
    case NOT_BEGINS_WITH
    case LIST_MEMBER_BEGINS_WITH
    case NOT_LIST_MEMBER_BEGINS_WITH
    case LIST_CONTAINS_ALL
    case NOT_LIST_CONTAINS_ALL
}
