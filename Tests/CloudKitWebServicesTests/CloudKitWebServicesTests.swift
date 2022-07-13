import XCTest
@testable import CloudKitWebServices

class BaseCloudKitWebServicesTests: XCTestCase {
    
    var services: CloudKitWebServices!
    
    override func setUp() async throws {
        let configurationUrl = loadResource(forResource: "configuration", withExtension: "json")!
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
    
    func loadResource(forResource name: String, withExtension ext: String?) -> URL? {
        guard let resourceURL = Bundle.module.resourceURL else { return nil }
        var url = Bundle.module.url(forResource: name, withExtension: ext) ?? resourceURL.appendingPathComponent("Resources/\(name)")
        if let ext = ext {
            url.appendPathExtension(ext)
        }
        return url
    }
}

final class CloudKitWebServicesTests: BaseCloudKitWebServicesTests {
    
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
    
    func testSaveRecords() async throws {
        let fileURL = loadResource(forResource: "File", withExtension: nil)!
        
        let record = CKRecord(
            recordName: "100020003_resource_indexes",
            recordType: "ResourceIndexes",
            fields: [
                "version": .int64(100020004),
                "indexes": .asset(try .init(fileURL: fileURL))
            ]
        )
        try await services.save(for: record)
            .recordName
            .assertEqual(expression: "100020003_resource_indexes")
    }
}

extension Equatable {
    func assertEqual(expression: Self) {
        XCTAssertEqual(self, expression)
    }
}
