//
//  CKRecordZone.swift
//  
//
//  Created by 翟泉 on 2022/6/27.
//

import Foundation

public struct CKRecordZone: Codable {
    
    public var zoneName: String = "_defaultZone"
    
    public var ownerRecordName: String? = nil
    
    public static var defaultZone: CKRecordZone { .init() }
}
