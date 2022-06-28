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

// MARK: - Send Request
extension CloudKitWebServices {
    func send<ResponseType: Codable>(subpath: String, params: Codable, responseType: ResponseType.Type, completionHandler: @escaping (Result<ResponseType, Error>) -> Void) {
        dispatch(subpath: subpath, params: params) { result in
            switch result {
            case .success(let success):
                do {
                    let result = try JSONDecoder().decode(responseType, from: success)
                    completionHandler(.success(result))
                } catch {
                    let err = error
                    do {
                        let error = try JSONDecoder().decode(CloudKitWebServicesError.self, from: success)
                        completionHandler(.failure(error))
                    } catch {
                        completionHandler(.failure(err))
                    }
                }
            case .failure(let failure):
                completionHandler(.failure(failure))
            }
        }
    }
    
    func dispatch<Params: Codable>(subpath: String, params: Params, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        do {
            let subpath = createSubpath(subpath: subpath)
            let request = try createSignedRequestWithServerToServerCertificate(body: params, subpath: subpath)
            session.dataTask(with: request) { data, response, error in
                if let data = data, let _ = response {
                    print(String(data: data, encoding: .utf8) ?? "")
                    completionHandler(.success(data))
                } else if let error = error {
                    completionHandler(.failure(error))
                }
            }.resume()
        } catch {
            completionHandler(.failure(error))
        }
    }
}

// MARK: - Utils
extension CloudKitWebServices {
    private func createSubpath(subpath: String) -> String {
        "/database/\(configuration.version)/\(configuration.container)/\(configuration.environment)/\(configuration.database)/\(subpath)"
    }
    
    private func createSignedRequestWithServerToServerCertificate<Body>(body: Body, subpath: String) throws -> URLRequest where Body: Codable {
        // https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitWebServicesReference/SettingUpWebServices.html#//apple_ref/doc/uid/TP40015240-CH24-SW1
        let httpBody = try JSONEncoder().encode(body)
        print(String(data: httpBody, encoding: .utf8) ?? "")
        
        // Date
        let date = ISO8601DateFormatter().string(from: .init())
        // Payload
        var sha256 = SHA256()
        sha256.update(data: httpBody)
        let payload = Data(sha256.finalize()).base64EncodedString()
        // Message
        let message = date + ":" + payload + ":" + subpath
        // Signature
//        let pemRepresentation = String(data: configuration.serverKey, encoding: .utf8)!
        let privateKey = try! P256.Signing.PrivateKey(pemRepresentation: configuration.serverKey)
        let signature = try privateKey.signature(for: message.data(using: .utf8)!).derRepresentation.base64EncodedString()
        
        var request = URLRequest(url: .init(string: "\(configuration.path)\(subpath)")!)
        print(request.url!.absoluteString)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(configuration.serverKeyID, forHTTPHeaderField: "X-Apple-CloudKit-Request-KeyID")
        request.addValue(date, forHTTPHeaderField: "X-Apple-CloudKit-Request-ISO8601Date")
        request.addValue(signature, forHTTPHeaderField: "X-Apple-CloudKit-Request-SignatureV1")
        return request
    }
}
