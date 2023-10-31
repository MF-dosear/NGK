//
//  NGToast.swift
//  NGSDK
//
//  Created by Paul on 2023/2/15.
//

import UIKit

enum TotasMode: String {
    case info    = "icon_toast_info"
    case success = "icon_toast_success"
    case fail    = "icon_toast_fail"
}

class Totas {
    
    class func style(style: SVProgressHUDStyle){
        
        SVProgressHUD.setDefaultStyle(style)
        SVProgressHUD.setDefaultMaskType(.gradient)
        SVProgressHUD.setDefaultAnimationType(.native)
    }
    
    class func show(){
        SVProgressHUD.show()
    }
    
    class func dismiss(completion: SVProgressHUDDismissCompletion? = nil){
        SVProgressHUD.dismiss(completion: completion)
    }
    
    class func show(_ title: String, _ mode: TotasMode = .info, completion: SVProgressHUDDismissCompletion? = nil){
        
        guard let image = UIImage.image(mode.rawValue) else { return print("\(mode.rawValue)图片不存在") }
        SVProgressHUD.show(image, status: title)
        SVProgressHUD.dismiss(withDelay: 1.6, completion: completion)
    }
}
