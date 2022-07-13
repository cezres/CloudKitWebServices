//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/6/29.
//

import Foundation

protocol CKRequest {
    
    associatedtype Response: Decodable
    
    func asURLRequest(configuration: CloudKitWebServices.Configuration) throws -> URLRequest

    static func decodeResponse(_ data: Data) throws -> Response
}

extension CKRequest {
    static func decodeResponse<T: Decodable>(_ data: Data, type: T.Type) throws -> T {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            let err = error
            do {
                throw try JSONDecoder().decode(CloudKitWebServicesError.self, from: data)
            } catch {
                throw err
            }
        }
    }
    
    static func decodeResponse(_ data: Data) throws -> Response {
        try decodeResponse(data, type: Response.self)
    }
}
