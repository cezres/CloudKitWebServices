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
        try await services.records(for: ["15C86234-0658-442F-A740-AC8610785A81"]).isEmpty.assertEqual(expression: false)
    }
    
    func testQueryRecords() async throws {
        let query = CKQuery(
            recordType: "Resource",
            filterBy: [
                .init("name", .EQUALS, .string("awsc_html")),
                .init("version", .LESS_THAN_OR_EQUALS, .int64(300000001))
            ],
            sortBy: [
                .init(fieldName: "version", ascending: false)
            ]
        )
        try await services.records(matching: query, desiredKeys: ["name", "version"], resultsLimit: 2)
            .matchResults
            .isEmpty
            .assertEqual(expression: false)
    }
    
//    func testSaveRecords() async throws {
//        let record = CKRecord(
//            recordName: "100020003_resource_indexes",
//            recordType: "ResourceIndexes",
//            fields: [
//                "version": .int64(100020004),
//                "indexes": .localAssetData("zzzzz".data(using: .utf8)!)
//            ]
//        )
//        try await services.save(for: record)
//            .get()
//            .recordName
//            .assertEqual(expression: "100020003_resource_indexes")
//    }
}

extension Equatable {
    func assertEqual(expression: Self) {
        XCTAssertEqual(self, expression)
    }
}
