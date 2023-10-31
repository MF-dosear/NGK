//
//  NGPhoneRegVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/22.
//

import UIKit

class NGPhoneRegVC: NGViewController {
    
    private let textField1 = NGTextField(.phone)
    private let textField2 = NGTextField(.code)
    private let textField3 = NGTextField(.password)
    private let btn = NGButton.button("注册")
    private var sendBtn: UIButton!
    var pro_view: NGProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NGEvent.upload(.phonereg_show)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("手机注册")
        
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
        
        // 位置设置
        let is_protocol = (NGNet.shared.config.is_user_protocol == "1")
        if (is_protocol == true) {
            
            pro_view = NGProtocol.init(frame: CGRectZero)
            view.addSubview(pro_view!)

            btn.snp.makeConstraints { make in
                
                make.left.equalTo(button_horizontal)
                make.right.equalTo(-button_horizontal)
                make.height.equalTo(button_height)
                make.top.equalTo(textField3.snp.bottom).offset(8)
            }
            
            pro_view!.snp.makeConstraints { make in
                make.left.equalTo(textfield_horizontal)
                make.right.equalTo(-textfield_horizontal)
                make.top.equalTo(btn.snp.bottom).offset(7)
                make.height.equalTo(49)
            }

        } else {
            // 没有注册协议
            btn.snp.makeConstraints { make in
                
                make.left.equalTo(button_horizontal)
                make.right.equalTo(-button_horizontal)
                make.height.equalTo(button_height)
                make.top.equalTo(textField3.snp.bottom).offset(25)
            }
        }
        
        sendBtn = textField2.addSendCodeBtn()
        sendBtn.addTarget(self, action: #selector(sendCode(_:)), for: .touchUpInside)
        
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
    }
    
    /// 发送验证码
    @objc private func sendCode(_ btn: UIButton){
        sendCode(btn, textField1, "3")
    }
    
    /// 手机号注册
    @objc private func btnAction(){
        if textField1.check() || textField2.check() || textField3.check(){
            return
        }
        
        let is_protocol = (NGNet.shared.config.is_user_protocol == "1")
        if (is_protocol && pro_view?.isSelected == false) {
            Totas.show(pro_view?.msg ?? "", .info)
            return;
        }
        
        if (checkCodeTime()) {
            return;
        }
        
        view.endEditing(true)
        
        let phone = textField1.text ?? ""
        let code = textField2.text ?? ""
        let password = textField3.text ?? ""
        
        NGNet.apiPhoneReg(phone, code, password) { [weak self] flag, data, msg, dict in
            if flag {
                Totas.show("注册成功", .success) {
                    self?.login(phone, password)
                    NGEvent.upload(.register_success)
                }
            } else {
                Totas.show(msg, .fail)
            }
        }
    }
}
