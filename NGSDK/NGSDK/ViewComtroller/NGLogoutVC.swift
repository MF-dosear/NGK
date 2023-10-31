//
//  NGLogoutVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/28.
//

import UIKit

class NGLogoutVC: NGViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("温馨提示")
        backBtn.removeFromSuperview()
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = "确定注销该账号吗？"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = tips_title_color
        view.addSubview(label)
        
        let btn1 = NGButton.button("确定")
        
        let btn2 = NGButton.button("取消")
        btn2.setBackgroundImage(UIImage.image("icon_按钮_normal"), for: .normal)
        
        view.addSubview(btn1)
        view.addSubview(btn2)
        
        btn1.snp.makeConstraints { make in
            make.bottom.equalTo(-30)
            make.height.equalTo(button_height)
            make.left.equalTo(button_horizontal)
            make.width.equalTo(btn2.snp.width)
        }
        
        btn2.snp.makeConstraints { make in
            make.centerY.equalTo(btn1.snp.centerY)
            make.height.equalTo(button_height)
            make.left.equalTo(btn1.snp.right).offset(15)
            make.right.equalTo(-button_horizontal)
        }
        
        label.snp.makeConstraints { make in
            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.top.equalTo(imgView.snp.bottom).offset(45)
            make.bottom.equalTo(btn1.snp.top).offset(-10)
        }
        
        btn1.addTarget(self, action: #selector(btn1Action), for: .touchUpInside)
        btn2.addTarget(self, action: #selector(btn2Action), for: .touchUpInside)
    }
    
    @objc private func btn1Action(){
        
        dismiss(animated: true, completion: {
            
            // 退出登录
            NGSDK.sdkLogout()
        })
    }
    
    @objc private func btn2Action(){
        
        dismiss(animated: true)
    }
}
