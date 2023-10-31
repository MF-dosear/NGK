//
//  NGButton.swift
//  NGSDK
//
//  Created by Paul on 2023/2/15.
//

import UIKit

class NGButton: UIButton {
    
    class func button(_ title: String) -> NGButton{
        
        let btn = NGButton.init(type: .custom)
        btn.setBackgroundImage(UIImage.image("icon_按钮_seleted"), for: .normal)
        btn.setTitleColor(button_title_color, for: .normal)
        btn.setTitleColor(button_high_title_color, for: .highlighted)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        return btn
    }
    
    class func smallButton(_ title: String) -> NGButton{
        let btn = NGButton.init(type: .custom)
        btn.setTitleColor(small_btn_normal_title_color, for: .normal)
        btn.setTitleColor(small_btn_high_title_color, for: .highlighted)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        return btn
    }
    
    deinit{
        print("\(NSStringFromClass(self.classForCoder))被销毁")
    }

}
