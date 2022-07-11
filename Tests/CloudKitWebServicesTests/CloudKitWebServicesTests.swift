import XCTest
@testable import CloudKitWebServices

final class CloudKitWebServicesTests: XCTestCase {
    
    var services: CloudKitWebServices!
    
    override func setUp() async throws {
        guard let resourceURL = Bundle.module.resourceURL else { return }
        let configurationUrl = Bundle.module.url(forResource: "configuration", withExtension: "json") ?? resourceURL.appendingPathComponent("Resources/configuration.json")
        let configurationData = try Data(contentsOf: configurationUrl)
        let configurationJson = try JSONSerialization.jsonObject(with: configurationData) as! [String: String]
        let configuration = CloudKitWebServices.Configuration(
            container: configurationJson["container"]!,
            environment: "development",
            database: "public",
            serverKeyID: configurationJson["serverKeyID"]!,
            serverKey: configurationJson["serverKey"]!
        )
        services = CloudKitWebServices(configuration: configuration)
    }
    
    func testFetchRecords() async throws {
        try await services.perform(
            CKFetchRecordsRequest(recordIds: ["15C86234-0658-442F-A740-AC8610785A81"])
        ).isEmpty.assertEqual(expression: false)
    }
    
    func testQueryRecords() async throws {
        try await services.perform(
            CKQueryRequest(
                query: .init(
                    recordType: "Resource",
                    filterBy: [
                        .init("name", .EQUALS, .string("awsc_html")),
                        .init("version", .LESS_THAN_OR_EQUALS, .int64(300000001))
                    ],
                    sortBy: [
                        .init(fieldName: "version", ascending: false)
                    ]
                ),
                resultsLimit: 2,
                desiredKeys: ["name", "version"]
            )
        ).matchResults.isEmpty.assertEqual(expression: false)
    }
    
    func testModifyRecords() async throws {
        try await services.perform(
            CKModifyRecordsRequest(
                operations: [
                    .init(
                        operationType: .forceUpdate,
                        record: .init(
                            recordName: "100020003_resource_indexes",
                            recordType: "ResourceIndexes",
                            fields: [
                                "version": .int64(100020003)
                            ]
                        )
                    )
                ]
            )
        ).isEmpty.assertEqual(expression: false)
    }

    func testUploadAsset() async throws {
        // Create upload url
        let createUploadUrlResult = try await services.perform(
            CKAssetsUploadRequest(
                tokens: [
                    .init(recordType: "ResourceIndexes", recordName: "100020003_resource_indexes", fieldName: "indexes")
                ]
            )
        )
        createUploadUrlResult.isEmpty.assertEqual(expression: false)
        
        // Uplaod data to url
        let url = createUploadUrlResult.first!.url
        let data = "Example1".data(using: .utf8)!
        let uploadDataResult = try await services.perform(
            CKUploadDataRequest(url: url, data: data)
        )
        
        // Save receipt to CloudKit
        let result = try await services.perform(
            CKModifyRecordsRequest(operations: [
                .init(
                    operationType: .forceUpdate,
                    record: .init(
                        recordName: "100020003_resource_indexes",
                        fields: [
                            "indexes": .uploadAsset(uploadDataResult)
                        ]
                    )
                )
            ])
        )
        result.isEmpty.assertEqual(expression: false)
    }
}

extension Equatable {
    func assertEqual(expression: Self) {
        XCTAssertEqual(self, expression)
    }
}
