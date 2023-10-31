//
//  NGResetVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/23.
//

import UIKit

class NGResetVC: NGViewController {
    
    var username: String?
    var token: String?
    
    private let textField1 = NGTextField(.command)
    private let textField2 = NGTextField(.password)
    private let btn = NGButton.button("重置密码")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("重置密码")
        
        view.addSubview(textField1)
        view.addSubview(textField2)
        view.addSubview(btn)
        
        textField1.snp.makeConstraints { make in

            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(imgView.snp.bottom).offset(70)
        }

        textField2.snp.makeConstraints { make in

            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(textField1.snp.bottom).offset(8)
        }
        
        btn.snp.makeConstraints { make in
            
            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)
            make.height.equalTo(button_height)
            make.top.equalTo(textField2.snp.bottom).offset(35)
        }
        
        textField1.text = username
        
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
    }
    
    /// 重置密码
    @objc private func btnAction(){
        if textField1.check() || textField2.check(){
            return
        }
        
        view.endEditing(true)
        
        let username = textField1.text ?? ""
        let password = textField2.text ?? ""
        
        NGNet.apiReset(username, token ?? "", password) { [weak self] flag, data, msg, dict in
            if flag {
                Totas.show("重置成功") {
                    self?.login(username, password)
                }
            } else {
                Totas.show(msg, .fail)
            }
        }
    }
}
