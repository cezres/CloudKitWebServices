//
//  CKRecordField.swift
//  
//
//  Created by 翟泉 on 2022/6/29.
//

import Foundation

public enum CKRecordFieldType: String, Codable {
    case STRING
    case ASSETID
    case INT64
}

public enum CKRecordField {
    case string(String)
    case int64(Int64)
    case asset(CKAsset)
    case any(type: CKRecordFieldType, value: any Codable)
    
    case localAssetUrl(URL)
    case localAssetData(Data)
}

extension CKRecordField {
    var stringValue: String {
        if case .string(let string) = self {
            return string
        } else {
            return ""
        }
    }
    
    var int64Value: Int64 {
        if case .int64(let int64) = self {
            return int64
        } else {
            return 0
        }
    }
    
    var assetValue: CKAsset {
        if case .asset(let recordAsset) = self {
            return recordAsset
        } else {
            return .init(fileChecksum: "", size: 0, downloadURL: "", receipt: nil)
        }
    }
    
    func optionalValue<T>() -> T? {
        value as? T
    }
}

extension CKRecordField: Codable {
    enum CodingKeys: String, CodingKey {
        case value
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(CKRecordFieldType.self, forKey: .type) {
        case .STRING:
            self = .string(try container.decode(String.self, forKey: .value))
        case .ASSETID:
            self = .asset(try container.decode(CKAsset.self, forKey: .value))
        case .INT64:
            self = .int64(try container.decode(Int64.self, forKey: .value))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(type, forKey: .type)
    }
}


extension CKRecordField {
    
    var type: CKRecordFieldType {
        switch self {
        case .string:
            return .STRING
        case .int64:
            return .INT64
        case .asset, .localAssetData, .localAssetUrl:
            return .ASSETID
        case .any(let type, _):
            return type
        }
    }
    
    var value: any Codable {
        switch self {
        case .string(let string):
            return string
        case .int64(let int64):
            return int64
        case .asset(let recordAsset):
            return recordAsset
        case .any(_, let value):
            return value
        case .localAssetUrl(let url):
            return url
        case .localAssetData(let data):
            return data
        }
    }
}
