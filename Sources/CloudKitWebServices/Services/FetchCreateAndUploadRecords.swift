//
//  FetchCreateAndUploadRecords.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation

public extension CloudKitWebServices {
    
    func fetch(withQuery query: Query, desiredKeys: [RecordFieldKey]? = nil, resultsLimit: Int = queryMaximumResults, completionHandler: @escaping (Result<(matchResults: RecordsResult, queryCursor: QueryCursor?), Error>) -> Void) {
        struct Params: Codable {
            var query: Query
            var zoneID: ZoneID = .defaultZone
            var resultsLimit: Int = 200
            var continuationMarker: String? = nil
            var desiredKeys: [String]? = nil
            var zoneWide: Bool? = nil
            var numbersAsStrings: Bool? = nil
        }
        struct Response: Codable {
            let records: RecordsResult
            let continuationMarker: QueryCursor?
        }
        let params = Params(query: query, resultsLimit: resultsLimit, desiredKeys: desiredKeys)
        send(subpath: "records/query", params: params, responseType: Response.self) { result in
            switch result {
            case .success(let success):
                completionHandler(.success((matchResults: success.records, queryCursor: success.continuationMarker)))
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
        
    func fetch(withRecordIds recordIds: [RecordId], desiredKeys: [RecordFieldKey]? = nil, completionHandler: @escaping (Result<RecordsResult, Error>) -> Void) {
        struct Params: Codable {
            var records: [LookupRecord]
            var zoneID: ZoneID? = nil
            var desiredKeys: [String]? = nil
            var numbersAsStrings: Bool? = nil
            
            struct LookupRecord: Codable {
                var recordName: String
                var desiredKeys: [String]? = nil
            }
        }
        struct Response: Codable {
            let records: RecordsResult
        }
        let params = Params(
            records: recordIds.map { .init(recordName: $0) },
            desiredKeys: desiredKeys
        )
        send(subpath: "records/lookup", params: params, responseType: Response.self) { result in
            switch result {
            case .success(let success):
                completionHandler(.success(success.records))
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
    
    func modifyRecords(operations: [RecordOperation], completionHandler: @escaping (Result<RecordsResult, Error>) -> Void) {
        let params = ModifyRecordsParams(operations: operations)
        send(subpath: "records/modify", params: params, responseType: ModifyRecordsResponse.self) { result in
            switch result {
            case .success(let success):
                completionHandler(.success(success.records))
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
}

private extension CloudKitWebServices {
    
    struct ModifyRecordsParams: Codable {
        var operations: [RecordOperation]
        var zoneID: ZoneID? = nil
        var atomic: Bool? = nil
        var desiredKeys: [String]? = nil
        var numbersAsStrings: Bool? = nil
    }
    
    struct ModifyRecordsResponse: Codable {
        let records: RecordsResult
    }
    
}
