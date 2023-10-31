//
//  NGFindVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/21.
//

import UIKit

class NGFindVC: NGViewController {
    
    private let textField1 = NGTextField(.phone)
    private let textField2 = NGTextField(.code)
    private let textField3 = NGTextField(.password)
    private let btn = NGButton.button("确认修改")
    private var sendBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField1.text = UserDefaults.standard.object(forKey: "phone_login_cache") as? String ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("找回密码")
        
        view.addSubview(textField1)
        view.addSubview(textField2)
        view.addSubview(textField3)
        view.addSubview(btn)
        
        textField1.snp.makeConstraints { make in

            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(imgView.snp.bottom).offset(55)
        }

        textField2.snp.makeConstraints { make in

            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(textField1.snp.bottom).offset(8)
        }
        
        textField3.snp.makeConstraints { make in

            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(textField2.snp.bottom).offset(8)
        }
        
        btn.snp.makeConstraints { make in
            
            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)
            make.height.equalTo(button_height)
            make.top.equalTo(textField3.snp.bottom).offset(25)
        }
        
        sendBtn = textField2.addSendCodeBtn()
        sendBtn.addTarget(self, action: #selector(sendCode(_:)), for: .touchUpInside)
        
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
    }
    
    /// 发送验证码
    @objc private func sendCode(_ btn: UIButton){
        sendCode(btn, textField1, "2")
    }
    
    /// 修改密码
    @objc private func btnAction(){
        if textField1.check() || textField2.check() || textField3.check(){
            return
        }
        
        if (checkCodeTime()) {
            return;
        }
        
        view.endEditing(true)
        
        let phone = textField1.text ?? ""
        let code = textField2.text ?? ""
        let password = textField3.text ?? ""
        
        NGNet.apiUpdatePassword(phone, code, password) { [weak self] flag, response, msg, dict in
            if flag {
                Totas.show("修改成功", .success) {
                    let data = response as? [String: Any]
                    let user_name = data?["user_name"] as? String ?? ""
                    self?.login(user_name, password)
                }
            } else {
                Totas.show(msg, .fail)
            }
        }
    }
}
