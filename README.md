# CloudKitWebServices
CloudKit Web Services


## Examples

```swift

// Init services
let configuration = ...
let services = CloudKitWebServices(configuration: configuration)

// Fetching Records by Record Name
let result = try await services.records(for: ["15C86234-0658-442F-A740-AC8610785A81"])
```
