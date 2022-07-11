//
//  File.swift
//  
//
//  Created by 翟泉 on 2022/6/28.
//

import Foundation

public struct CKAsset: Codable {
    
    public var fileChecksum: String
    
    public var size: UInt
    
    public let downloadURL: String
    
    public var receipt: String?
}
