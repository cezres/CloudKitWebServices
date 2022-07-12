//
//  CKUploadDataRequest.swift
//  
//
//  Created by 翟泉 on 2022/6/29.
//

import Foundation

public protocol CKUploadData {
    func load() throws -> Data
}

extension URL: CKUploadData {
    public func load() throws -> Data {
        try Data(contentsOf: self)
    }
}

extension Data: CKUploadData {
    public func load() throws -> Data {
        self
    }
}

public struct CKUploadDataRequest {
    
    public var url: URL
    
    public var data: CKUploadData
    
    public var filename: String = UUID().uuidString
}

public struct CKAssetUploadResponse: Codable {
    public let size: UInt
    public let fileChecksum: String
    public let receipt: String
}

extension CKUploadDataRequest: CKRequest {
    public typealias Response = CKAssetUploadResponse
    
    public func asURLRequest(configuration: CloudKitWebServices.Configuration) throws -> URLRequest {
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("multipart/form-data; boundary=----\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = "------\(boundary)\r\n".data(using: .utf8) ?? Data()
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n\r\n".data(using: .utf8) ?? Data())
        body.append(try data.load())
        body.append("\r\n------\(boundary)--\r\n".data(using: .utf8) ?? Data())
        request.httpBody = body
        return request
    }
    
    public static func decodeResponse(_ data: Data) throws -> CKAssetUploadResponse {
        struct Response: Decodable {
            let singleFile: CKAssetUploadResponse
        }
        return try decodeResponse(data, type: Response.self).singleFile
    }
}


