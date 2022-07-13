//
//  CKAssetUploadDataRequest.swift
//  
//
//  Created by 翟泉 on 2022/6/29.
//

import Foundation

protocol CKAssetData {
    func load() throws -> Data
}

extension URL: CKAssetData {
    public func load() throws -> Data {
        try Data(contentsOf: self)
    }
}

extension Data: CKAssetData {
    public func load() throws -> Data {
        self
    }
}

struct CKAssetUploadDataRequest {
    
    var url: URL
    
    var data: CKAssetData
    
    var filename: String = UUID().uuidString
}

extension CKAssetUploadDataRequest: CKRequest {
    public typealias Response = CKAsset
    
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
    
    public static func decodeResponse(_ data: Data) throws -> CKAsset {
        struct Response: Decodable {
            let singleFile: CKAsset
        }
        return try decodeResponse(data, type: Response.self).singleFile
    }
}


