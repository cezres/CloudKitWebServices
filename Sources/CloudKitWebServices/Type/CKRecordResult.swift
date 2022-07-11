//
//  CKRecordResult.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation

public typealias CKRecordResult = Result<CKRecord, CKRecordOperationError>

public typealias RecordsResult = [CKRecordResult]

public struct CKRecordOperationError: Error, Codable {
    // The name of the record that the operation failed on.
    public let recordName: String
    // A string indicating the reason for the error.
    public let reason: String
    // A string containing the code for the error that occurred.
    public let serverErrorCode: CKServicesError
    // The suggested time to wait before trying this operation again. If this key is not set, the operation can’t be retried.
    public let retryAfter: TimeInterval?
    // A unique identifier for this error.
    public let uuid: String?
    // A redirect URL for the user to securely sign in using their Apple ID. This key is present when serverErrorCode is AUTHENTICATION_REQUIRED.
    public let redirectURL: String?
}

public enum CKServicesError: String, Error, Codable {
    // 403: You don’t have permission to access the endpoint, record, zone, or database.
    case ACCESS_DENIED
    // 400: An atomic batch operation failed.
    case ATOMIC_ERROR
    // 401: Authentication was rejected.
    case AUTHENTICATION_FAILED
    // 421: The request requires authentication but none was provided.
    case AUTHENTICATION_REQUIRED
    // 400: The request was not valid.
    case BAD_REQUEST
    // 409: The recordChangeTag value expired. (Retry the request with the latest tag.)
    case CONFLICT
    // 409: The resource that you attempted to create already exists.
    case EXISTS
    // 500: An internal error occurred.
    case INTERNAL_ERROR
    // 404: The resource was not found.
    case NOT_FOUND
    // 413: If accessing the public database, you exceeded the app’s quota. If accessing the private database, you exceeded the user’s iCloud quota.
    case QUOTA_EXCEEDED
    // 429: The request was throttled. Try the request again later.
    case THROTTLED
    // 503: An internal error occurred. Try the request again.
    case TRY_AGAIN_LATER
    // 412: The request violates a validating reference constraint.
    case VALIDATING_REFERENCE_ERROR
    // 404: The zone specified in the request was not found.
    case ZONE_NOT_FOUND
}

extension Result: Codable, CustomStringConvertible where Success == CKRecord, Failure == CKRecordOperationError {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .success(try container.decode(Success.self))
        } catch {
            self = .failure(try container.decode(Failure.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .success(let success):
            var values = encoder.singleValueContainer()
            try values.encode(success)
        case .failure(let failure):
            var values = encoder.singleValueContainer()
            try values.encode(failure)
        }
    }
    
    public var description: String {
        switch self {
        case .success(let success):
            return "\(success)"
        case .failure(let failure):
            return "\(failure)"
        }
    }
    
}
