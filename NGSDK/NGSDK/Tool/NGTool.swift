//
//  NGTool.swift
//  NGSDK
//
//  Created by Paul on 2023/2/14.
//

import UIKit

public class NGTool {
    
    public class func currentvc() -> UIViewController{
        
        let rootVc = UIApplication.shared.keyWindow?.rootViewController
        let currentVc = getCurrentVcFrom(rootVc!)
        
        return currentVc
    }
    
    class private func getCurrentVcFrom(_ rootVc:UIViewController) -> UIViewController{
        
     var currentVc:UIViewController
     var rootCtr = rootVc
        
     if(rootCtr.presentedViewController != nil) {
         
       rootCtr = rootVc.presentedViewController!
     }
        
     if rootVc.isKind(of:UITabBarController.classForCoder()) {
         
       currentVc = getCurrentVcFrom((rootVc as! UITabBarController).selectedViewController!)
     } else if rootVc.isKind(of:UINavigationController.classForCoder()){
         
       currentVc = getCurrentVcFrom((rootVc as! UINavigationController).visibleViewController!)
     } else {
         
       currentVc = rootCtr
     }
        
     return currentVc
    }
}



