import Foundation
import CryptoKit

public struct CloudKitWebServices {
    public private(set) var text = "Hello, World!"

    public let configuration: Configuration
    private let session: URLSession
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        session = .init(configuration: .default)
    }
}

public extension CloudKitWebServices {
    struct Configuration: Codable, Sendable {
        public var path: String = "https://api.apple-cloudkit.com"
        public var version: Int = 1
        public var container: String
        public var environment: String
        public var database: String
        public var serverKeyID: String
        public var serverKey: String
    }
}

public struct CloudKitWebServicesError: Error, Codable {
    public let uuid: String
    public let serverErrorCode: String
    public let reason: String
}

extension CloudKitWebServices {
    func perform<Request: CKRequest>(_ request: Request) async throws -> Request.Response {
        let request = try request.asURLRequest(configuration: configuration)
        let (data, _) = try await session.data(for: request)
        print(request.url?.absoluteString ?? "")
        print(String(data: request.httpBody ?? .init(), encoding: .utf8) ?? "")
        print(String(data: data, encoding: .utf8) ?? "")
        return try Request.decodeResponse(data)
    }
}

extension CloudKitWebServices {
    public func records(for ids: [CKRecordID], desiredKeys: [CKRecordFieldKey]? = nil) async throws -> [CKRecordResult] {
        try await perform(
            CKFetchRecordsRequest(recordIds: ids, desiredKeys: desiredKeys)
        )
    }
    
    public func records(matching query: CKQuery, inZoneWith zoneID: CKRecordZone? = nil, desiredKeys: [CKRecordFieldKey]? = nil, resultsLimit: Int = CKQueryRequest.maximumResults) async throws -> CKQueryResult {
        try await perform(
            CKQueryRequest(query: query, zoneID: zoneID, resultsLimit: resultsLimit, desiredKeys: desiredKeys)
        )
    }
    
    public func modifyRecords(records: [CKRecord], type: CKRecordModifyType) async throws -> [CKRecordResult] {
        let records = try await uploadLocalAsset(records)
        return try await perform(
            CKModifyRecordsRequest(records: records, operationType: type)
        )
    }
    
    public func deleteRecords(for ids: [CKRecordID]) async throws -> [CKRecordResult] {
        try await modifyRecords(records: ids.map { .init(recordName: $0) }, type: .delete)
    }
    
    public func save(for records: [CKRecord]) async throws -> [CKRecordResult] {
        try await modifyRecords(records: records, type: .forceUpdate)
    }
    
    public func save(for record: CKRecord) async throws -> CKRecordResult {
        try await modifyRecords(records: [record], type: .forceUpdate).first!
    }
}

private extension CloudKitWebServices {
    
    func uploadLocalAsset(_ records: [CKRecord]) async throws -> [CKRecord] {
        
        // Filter local assets
        typealias UploadLocalAsset = (recordIndex: Int, fieldName: String, data: CKUploadData)
        let localAssets = records.enumerated().flatMap { (index, record) -> [UploadLocalAsset] in
            record.fields.compactMap { (key, value) -> UploadLocalAsset? in
                switch value {
                case .localAssetUrl(let url):
                    return (index, key, url)
                case .localAssetData(let data):
                    return (index, key, data)
                default:
                    return nil
                }
            }
        }
        
        // Create upload urls
        let createUploadUrlResults = try await perform(
            CKAssetsUploadRequest(
                tokens: localAssets.map {
                    .init(
                        recordType: records[$0.recordIndex].recordType,
                        recordName: records[$0.recordIndex].recordName,
                        fieldName: $0.fieldName
                    )
                }
            )
        )
        
        // Upload data
        typealias UploadDataResult = (recordIndex: Int, fieldName: String, response: CKAssetUploadResponse)
        let results = try await withThrowingTaskGroup(of: UploadDataResult.self, returning: [UploadDataResult].self) { group in
            createUploadUrlResults.enumerated().forEach { (index, uploadUrl) in
                group.addTask {
                    let result = try await self.perform(
                        CKUploadDataRequest(url: uploadUrl.url, data: localAssets[index].data)
                    )
                    return (localAssets[index].recordIndex, localAssets[index].fieldName, result)
                }
            }
            return try await group.reduce([], { $0 + [$1] })
        }
        
        // Replace record fields
        var records = records
        results.forEach { result in
            records[result.recordIndex].fields[result.fieldName] = .assetUploadReceipt(result.response)
        }
        return records
    }
}
