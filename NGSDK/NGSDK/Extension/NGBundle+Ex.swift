//
//  Bundle.swift
//  NGSDK
//
//  Created by Paul on 2023/2/28.
//

import Foundation

extension Bundle {
    
    class func sdkBundle() -> Bundle?{
        
        let path = "Frameworks/NGSDK.framework/images"
        if let url = Bundle.main.url(forResource: path, withExtension: "bundle") {
            
            return Bundle(url: url)
        } else {
            print("Bundle地址错误：\(path)，请修改")
            return nil
        }
    }
}
