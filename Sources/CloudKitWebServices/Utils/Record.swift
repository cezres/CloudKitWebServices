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
        
        if let value = value as? String {
            try values.encode(value, forKey: .value)
        } else if let value = value as? Int64 {
            try values.encode(value, forKey: .value)
        } else if let value = value as? Int {
            try values.encode(value, forKey: .value)
        } else if let value = value as? RecordAssetField {
            try values.encode(value, forKey: .value)
        } else {
            fatalError()
        }
        try values.encode(type, forKey: .type)
    }
}

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
