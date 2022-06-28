//
//  Query.swift
//  
//
//  Created by 翟泉 on 2022/6/27.
//

import Foundation

public typealias QueryCursor = String
public let queryMaximumResults: Int = 200


public struct Query: Codable {
    public var recordType: String
    public var filterBy: [QueryFilter]
    public var sortBy: [QuerySortDescriptor]
}

public struct QueryFilter: Codable {
    public var fieldName: String
    public var comparator: QueryFilterComparator
    public var fieldValue: RecordField
}

public struct QuerySortDescriptor: Codable {
    public var fieldName: String
    public var ascending: Bool
}

public enum QueryFilterComparator: String, Codable {
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
