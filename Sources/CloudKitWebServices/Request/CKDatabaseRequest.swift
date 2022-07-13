//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation
import CryptoKit

protocol CKDatabaseRequest: CKRequest, Encodable {
    
    static var subpath: String { get }
}

extension CKDatabaseRequest {
    public func asURLRequest(configuration: CloudKitWebServices.Configuration) throws -> URLRequest {
        let subpath = "/database/\(configuration.version)/\(configuration.container)/\(configuration.environment)/\(configuration.database)/\(Self.subpath)"
        
        let httpBody = try JSONEncoder().encode(self)
        
        // Date
        let date = ISO8601DateFormatter().string(from: .init())
        // Payload
        var sha256 = SHA256()
        sha256.update(data: httpBody)
        let payload = Data(sha256.finalize()).base64EncodedString()
        // Message
        let message = date + ":" + payload + ":" + subpath
        // Signature
        let privateKey = try! P256.Signing.PrivateKey(pemRepresentation: configuration.serverKey)
        let signature = try privateKey.signature(for: message.data(using: .utf8)!).derRepresentation.base64EncodedString()
        
        var request = URLRequest(url: .init(string: "\(configuration.path)\(subpath)")!)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(configuration.serverKeyID, forHTTPHeaderField: "X-Apple-CloudKit-Request-KeyID")
        request.addValue(date, forHTTPHeaderField: "X-Apple-CloudKit-Request-ISO8601Date")
        request.addValue(signature, forHTTPHeaderField: "X-Apple-CloudKit-Request-SignatureV1")
        return request
    }
}

public struct CKDataSizeLimits {

    public static let maximumNumberOfOperationsInRequest = 200 
    
    public static let maximumNumberOfRecordsInResponse = 200

    public static let maximumNumberOfTokensInRequest = 200
}
