//
//  Decoder+DefalutValue.swift
//  
//
//  Created by 翟泉 on 2022/7/11.
//

import Foundation

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

extension Optional: DefaultValue where Wrapped: DefaultValue {
    public static func defaultValue() -> Optional<Wrapped> {
        Wrapped.defaultValue()
    }
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
