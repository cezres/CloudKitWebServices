//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation

public struct CKAsset: Codable {
    
    public let fileChecksum: String
    
    public let size: UInt
    
    public let downloadURL: String
    
    public let receipt: String?
    
    init(fileChecksum: String, size: UInt, downloadURL: String, receipt: String?) {
        self.fileChecksum = fileChecksum
        self.size = size
        self.downloadURL = downloadURL
        self.receipt = receipt
    }
    
    enum CodingKeys: CodingKey {
        case fileChecksum
        case size
        case downloadURL
        case receipt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.fileChecksum = try container.decode(String.self, forKey: .fileChecksum)
        self.size = try container.decode(UInt.self, forKey: .size)
        self.downloadURL = try container.decode(String.self, forKey: .downloadURL)
        self.receipt = container.decodeValue(String?.self, forKey: .receipt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.fileChecksum, forKey: .fileChecksum)
        try container.encode(self.size, forKey: .size)
        if !downloadURL.isEmpty {
            try container.encode(self.downloadURL, forKey: .downloadURL)
        }
        if let receipt = receipt {
            try container.encodeIfPresent(receipt, forKey: .receipt)
        }
    }
}
