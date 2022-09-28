//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/8/30.
//

import Foundation

public struct CKFetchingRecordChangesRequest {
    let zoneID: CKRecordZone = .defaultZone
    let resultsLimit: Int
}

extension CKFetchingRecordChangesRequest: CKDatabaseRequest {
    
    static var subpath: String = "/zones/changes"
    
    typealias Response = [CKRecord]
}
