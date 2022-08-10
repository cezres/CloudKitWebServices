# CloudKitWebServices
CloudKit Web Services


## Examples

```swift

// Init services
let configuration = ...
let services = CloudKitWebServices(configuration: configuration)

// Fetching Records by Record Name
let result = try await services.records(for: ["15C86234-0658-442F-A740-AC8610785A81"])

// Fetching Records Using a Query
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

// Modifying Records
let record = CKRecord(
    recordName: "100020003_resource_indexes",
    recordType: "ResourceIndexes",
    fields: [
        "version": .int64(100020004),
        "indexes": .asset(try .init(fileURL: fileURL))
    ]
)
try await services.save(for: record)
```
