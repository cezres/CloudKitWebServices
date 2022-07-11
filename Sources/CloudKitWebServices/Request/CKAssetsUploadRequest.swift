//
//  CKAssetsUploadRequest.swift
//  
//
//  Created by 翟泉 on 2022/6/29.
//

import Foundation

struct CKAssetsUploadRequest: CKDatabaseRequest {

    static var subpath: String = "assets/upload"
    
    typealias Response = [CKAssetUploadUrl]

    public var tokens: [CKAssetUpload]
    
    public var zoneID: CKRecordZone?
}

extension CKAssetsUploadRequest {
    static func decodeResponse(_ data: Data) throws -> [CKAssetUploadUrl] {
        struct CKAssetsUploadResponse: Decodable {
            let tokens: [CKAssetUploadUrl]
        }
        return try decodeResponse(data, type: CKAssetsUploadResponse.self).tokens
    }
}

struct CKAssetUpload: Encodable {

    var recordType: String
    
    var recordName: String?
    
    var fieldName: String
}

struct CKAssetUploadUrl: Decodable {
    
    var recordName: String
    
    var fieldName: String
    
    var url: URL
}
