//
//  NGLabel.swift
//  NGSDK
//
//  Created by Paul on 2023/2/15.
//

import UIKit

class NGLabel: UILabel{
    
    class func label(_ text: String) -> NGLabel{
        let label = NGLabel.init()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = tips_title_color
        label.textAlignment = .center
        return label
    }
    
    deinit{
        print("\(NSStringFromClass(self.classForCoder))被销毁")
    }
}
