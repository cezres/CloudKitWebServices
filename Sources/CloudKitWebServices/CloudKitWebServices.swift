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
        try await perform(
            CKModifyRecordsRequest(records: records, operationType: type)
        )
    }
    
    public func deleteRecords(for ids: [CKRecordID]) async throws -> [CKRecordResult] {
        try await perform(
            CKModifyRecordsRequest(records: ids.map { .init(recordName: $0) }, operationType: .delete)
        )
    }
    
    public func save(for records: [CKRecord]) async throws -> [CKRecordResult] {
        try await perform(
            CKModifyRecordsRequest(records: records, operationType: .forceUpdate)
        )
    }
}
