//
//  Dictionary.swift
//  NGSDK
//
//  Created by Paul on 2023/2/28.
//

import Foundation

extension Dictionary {
    
    func jsonString() -> String?{
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            
            let jsonString = String.init(data: jsonData, encoding: .utf8)
            return jsonString
        }
        
        return nil
    }
}
