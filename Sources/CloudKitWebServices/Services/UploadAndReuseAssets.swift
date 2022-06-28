//
//  UploadAndReuseAssets.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation

public extension CloudKitWebServices {
    
    struct UploadAsset: Codable {
        public var recordName: String
        public var recordType: String
        public var fieldName: String
    }
    
    struct UploadAssetUrl: Codable {
        public let recordName: String
        public let fieldName: String
        public let url: URL
    }
    
    func uploadAsset(_ tokens: [UploadAsset], inZoneWith zoneID: ZoneID? = nil, completionHandler: @escaping (Result<[UploadAssetUrl], Error>) -> Void) {
        let params = UploadAssetsParams(tokens: tokens, zoneID: zoneID)
        send(subpath: "assets/upload", params: params, responseType: UploadAssetsResponse.self) { result in
            switch result {
            case .success(let success):
                completionHandler(.success(success.tokens))
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
    
}

private extension CloudKitWebServices {
    
    struct UploadAssetsParams: Codable {
        var tokens: [UploadAsset]
        var zoneID: ZoneID?
    }
    
    struct UploadAssetsResponse: Codable {
        let tokens: [UploadAssetUrl]
    }
    
}
