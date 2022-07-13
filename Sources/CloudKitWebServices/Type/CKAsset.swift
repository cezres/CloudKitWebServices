//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation

public struct CKAsset: Codable {
    
    public let fileChecksum: String?
    
    public let size: UInt
    
    public let fileURL: URL?
    
    let receipt: String?
    
    public init(fileURL: URL) throws {
        self.fileChecksum = nil
        self.size = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as! UInt
        self.fileURL = fileURL
        self.receipt = nil
        
        if size > 1024 * 1024 * 15 {
            throw NSError(domain: "maximum file size is 15 MB", code: -1)
        }
    }
    
    init(fileChecksum: String?, size: UInt, downloadURL: String, receipt: String?) {
        self.fileChecksum = fileChecksum
        self.size = size
        self.fileURL = URL(string: downloadURL)
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
        if let downloadURL = try container.decodeIfPresent(String.self, forKey: .downloadURL) {
            self.fileURL = URL(string: downloadURL.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? downloadURL)
        } else {
            self.fileURL = nil
        }
        self.receipt = try container.decodeIfPresent(String.self, forKey: .receipt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.fileChecksum, forKey: .fileChecksum)
        try container.encode(self.size, forKey: .size)
        if let fileURL = fileURL {
            try container.encode(fileURL.absoluteString, forKey: .downloadURL)
        }
        if let receipt = receipt {
            try container.encodeIfPresent(receipt, forKey: .receipt)
        }
    }
}
