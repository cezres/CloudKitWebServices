import XCTest
@testable import CloudKitWebServices

final class CloudKitWebServicesTests: XCTestCase {
    
    var services: CloudKitWebServices!
    
    override func setUp() async throws {
        guard let resourceURL = Bundle.module.resourceURL else { return }
        let configurationUrl = resourceURL.appendingPathComponent("Resources/configuration.json")
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
    
    func testFetchWithRecordIds() async throws {
        let result = try await services.records(for: ["15C86234-0658-442F-A740-AC8610785A81", "nanami"])
        print(result)
    }
    
    func testFetchWithQuery() async throws {
        let result = try await withCheckedThrowingContinuation { continuation in
            self.services.fetch(
                withQuery: .init(
                    recordType: "Resource",
                    filterBy: [
                        .init(fieldName: "name", comparator: .EQUALS, fieldValue: .init("awsc_html")),
                        .init(fieldName: "version", comparator: .LESS_THAN_OR_EQUALS, fieldValue: .init(300000001)),
                    ],
                    sortBy: [
                        .init(fieldName: "version", ascending: false)
                    ]
                ),
                resultsLimit: 2
            ) { result in
                continuation.resume(with: result)
            }
        }
        print(result)
    }
    
//    func testModifyRecords() async throws {
//        let result = try await withCheckedThrowingContinuation { continuation in
//            self.services.modifyRecords(
//                operations: [
//                    .init(
//                        operationType: .forceUpdate,
//                        record: .init(
//                            recordName: "300000002_resource_indexes",
//                            recordType: "ResourceIndexes",
//                            fields: [
//                                "version": .init(300000002)
//                            ]
//                        )
//                    )
//                ]
//            ) { result in
//                continuation.resume(with: result)
//            }
//        }
//        print(result)
//    }
//    
//    func testUploadAsset() async throws {
//        let result = try await withCheckedThrowingContinuation { continuation in
//            self.services.uploadAsset([
//                .init(recordName: "300000002_resource_indexes", recordType: "ResourceIndexes", fieldName: "indexes")
//            ]) { result in
//                continuation.resume(with: result)
//            }
//        }
//        print(result)
//    }
}
