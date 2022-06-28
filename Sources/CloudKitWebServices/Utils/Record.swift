//
//  Record.swift
//  
//
//  Created by 翟泉 on 2022/6/27.
//

import Foundation

public typealias RecordId = String
public typealias RecordFieldKey = String

public struct Record: Codable {
    public let recordName: String
    public let recordType: String
    public let fields: [String: RecordField]
    public let pluginFields: [String: RecordField]
    public let recordChangeTag: String
    public let created: RecordTimestamp
    public let modified: RecordTimestamp
    public let deleted: Bool
}

extension Record: CustomStringConvertible {
    public var description: String {
        """
        \(recordType): \(recordName)
        """
    }
}

public struct RecordTimestamp: Codable {
    public let timestamp: TimeInterval
    public let userRecordName: String
    public let deviceID: String
}

// MARK: Record Fields

public struct RecordField: Codable {
    public let value: Any
    public let type: RecordFieldType
    
    public init(_ value: RecordFieldValue) {
        self.value = value
        self.type = Swift.type(of: value).type
    }
    
    public func stringValue() -> String {
        guard type == .STRING else {
            return ""
        }
        return value as! String
    }
    
    enum CodingKeys: String, CodingKey {
        case value
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        type = try values.decode(RecordFieldType.self, forKey: .type)
        switch type {
        case .STRING:
            value = try values.decode(String.self, forKey: .value)
        case .ASSETID:
            value = try values.decode(RecordAssetField.self, forKey: .value)
        case .INT64:
            value = try values.decode(Int64.self, forKey: .value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        
        if let value = value as? Codable {
            try values.encode(value, forKey: .value)
        }
        try values.encode(type, forKey: .type)
    }
}

//protocol RecordField: Codable {
//    associatedtype Value: RecordFieldValue
//    var value: Value { get set }
//    var type: RecordFieldType { get set }
//}
//
//struct RecordStringField: RecordField {
//    var value: String
//    var type: RecordFieldType = .STRING
//}
//
//struct RecordInt64Field: RecordField {
//    var value: Int64
//    var type: RecordFieldType = .INT64
//}
//
//struct RecordAssetField: RecordField {
//    var value: Value
//    var type: RecordFieldType = .ASSETID
//
//    struct Value: RecordFieldValue {
//        let fileChecksum: String
//        let size: UInt
//        let downloadURL: String
//    }
//}

public enum RecordFieldType: String, Codable {
    case STRING
    case ASSETID
    case INT64
}

public protocol RecordFieldValue: Codable {
    static var type: RecordFieldType { get }
}
extension String: RecordFieldValue {
    public static var type: RecordFieldType { .STRING }
}
extension Int64: RecordFieldValue {
    public static var type: RecordFieldType { .INT64 }
}
extension Int: RecordFieldValue {
    public static var type: RecordFieldType { .INT64 }
}
public struct RecordAssetField: RecordFieldValue {
    public static var type: RecordFieldType { .ASSETID }
    
    let fileChecksum: String
    let size: UInt
    let downloadURL: URL
}
