//
//  CKRecord.swift
//  
//
//  Created by 翟泉 on 2022/6/27.
//

import Foundation

public typealias CKRecordID = String

public typealias CKRecordFieldKey = String

public struct CKRecord: Codable {
    
    public let recordName: String

    public let recordType: String

    public let fields: [String: CKRecordField]

    public let recordChangeTag: String

    public let created: CKRecordTimestamp

    public let modified: CKRecordTimestamp

    public let deleted: Bool
    
    public subscript<T>(string: String) -> T? {
        fields[string]?.value as? T
    }
    
    public subscript(string: String) -> CKRecordField? {
        fields[string]
    }
    
    public init(recordName: String, recordType: String = "", fields: [String : CKRecordField] = [:]) {
        self.recordName = recordName
        self.recordType = recordType
        self.fields = fields
        self.recordChangeTag = ""
        self.created = .init(timestamp: 0, userRecordName: "", deviceID: "")
        self.modified = .init(timestamp: 0, userRecordName: "", deviceID: "")
        self.deleted = false
    }
    
    enum CodingKeys: CodingKey {
        case recordName
        case recordType
        case fields
        case recordChangeTag
        case created
        case modified
        case deleted
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.recordName = try container.decode(String.self, forKey: .recordName)
        self.recordType = container.decodeValue(String.self, forKey: .recordType)
        self.fields = try container.decode([String : CKRecordField].self, forKey: .fields)
        self.recordChangeTag = try container.decode(String.self, forKey: .recordChangeTag)
        self.created = container.decodeValue(CKRecordTimestamp.self, forKey: .created)
        self.modified = container.decodeValue(CKRecordTimestamp.self, forKey: .modified)
        self.deleted = container.decodeValue(Bool.self, forKey: .deleted)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.recordName, forKey: .recordName)
        if !recordType.isEmpty {
            try container.encode(self.recordType, forKey: .recordType)
        }
        try container.encode(self.fields, forKey: .fields)
        if !recordChangeTag.isEmpty {
            try container.encode(self.recordChangeTag, forKey: .recordChangeTag)
        }
        if created.timestamp != 0 {
            try container.encode(self.created, forKey: .created)
        }
        if modified.timestamp != 0 {
            try container.encode(self.modified, forKey: .modified)
        }
        if deleted {
            try container.encode(self.deleted, forKey: .deleted)
        }
    }
}

public struct CKRecordTimestamp: Codable {
    
    public let timestamp: TimeInterval
    
    public let userRecordName: String
    
    public let deviceID: String
}


extension Optional {
    func `default`(_ value: Wrapped) -> Wrapped {
        switch self {
        case .none:
            return value
        case .some(let wrapped):
            return wrapped
        }
    }
}

extension KeyedDecodingContainer {
    public func decodeValue<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key, defaultValue: T) -> T {
        do {
            return try decode(type, forKey: key)
        } catch {
            return defaultValue
        }
    }
    
    public func decodeValue<T: Decodable>(_ type: T.Type, forKey key: KeyedDecodingContainer<K>.Key) -> T where T: DefaultValue {
        do {
            return try decode(type, forKey: key)
        } catch {
            return T.defaultValue()
        }
    }
}

public protocol DefaultValue {
    static func defaultValue() -> Self
}


extension CKRecordTimestamp: DefaultValue {
    public static func defaultValue() -> CKRecordTimestamp {
        .init(timestamp: 0, userRecordName: "", deviceID: "")
    }
}

extension Bool: DefaultValue {
    public static func defaultValue() -> Bool {
        false
    }
}

extension String: DefaultValue {
    public static func defaultValue() -> String {
        ""
    }
}