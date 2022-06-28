//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/6/27.
//

import Foundation

extension CloudKitWebServices {
    func records(for ids: [String]) async throws -> RecordsResult {
        try await withCheckedThrowingContinuation { continuation in
            self.fetch(withRecordIds: ids) { result in
                continuation.resume(with: result)
            }
        }
    }
}
