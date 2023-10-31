//
//  NGFastRegVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/21.
//

import UIKit

class NGFastRegVC: NGViewController {
    
    let textField1 = NGTextField(.username)
    let textField2 = NGTextField(.password)
    let btn = NGButton.button("注册")
    var pro_view: NGProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let text = String(format: "vm%.0f", Date().timeIntervalSince1970)
        textField1.text = text
        textField2.text = "\(text.md5().prefix(6))"
        
        NGEvent.upload(.quickreg_show)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("快速注册")
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = "系统已自动分配账号，为了方便记忆，您可自行设置"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = tips_title_color
        view.addSubview(label)
        
        // 账号
        view.addSubview(textField1)
        
        // 密码
        view.addSubview(textField2)
        
        // 注册
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(regiestClick), for: .touchUpInside)
        
        /// 手机注册
        let phoneBtn = NGButton.smallButton("手机注册")
        phoneBtn.contentHorizontalAlignment = .right
        view.addSubview(phoneBtn)

        let is_protocol = (NGNet.shared.config.is_user_protocol == "1")
        let height = is_protocol ? 50 : 55

        label.snp.makeConstraints { make in
            
            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.top.equalTo(imgView.snp.bottom).offset(20)
            make.height.equalTo(height)
        }
        
        textField1.snp.makeConstraints { make in

            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(label.snp.bottom).offset(0)
        }

        textField2.snp.makeConstraints { make in

            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(textField1.snp.bottom).offset(8)
        }
        
        // 位置设置
        if (is_protocol == true) {
            
            pro_view = NGProtocol.init(frame: CGRectZero)
            view.addSubview(pro_view!)

            btn.snp.makeConstraints { make in
                
                make.left.equalTo(button_horizontal)
                make.right.equalTo(-button_horizontal)
                make.height.equalTo(button_height)
                make.top.equalTo(textField2.snp.bottom).offset(8)
            }
            
            phoneBtn.snp.makeConstraints { make in
                make.right.equalTo(-button_horizontal)
                make.width.equalTo(btn.snp.width).multipliedBy(0.5)
                make.height.equalTo(samll_button_height)
                make.top.equalTo(btn.snp.bottom).offset(8)
            }
            
            pro_view!.snp.makeConstraints { make in
                make.left.equalTo(textfield_horizontal)
                make.right.equalTo(-textfield_horizontal)
                make.top.equalTo(phoneBtn.snp.bottom).offset(0)
                make.height.equalTo(49)
            }

        } else {
            // 没有注册协议
            btn.snp.makeConstraints { make in
                
                make.left.equalTo(button_horizontal)
                make.right.equalTo(-button_horizontal)
                make.height.equalTo(button_height)
                make.top.equalTo(textField2.snp.bottom).offset(16)
            }
            
            phoneBtn.snp.makeConstraints { make in
                make.right.equalTo(-button_horizontal)
                make.width.equalTo(btn.snp.width).multipliedBy(0.5)
                make.height.equalTo(samll_button_height)
                make.top.equalTo(btn.snp.bottom).offset(8)
            }
        }
        
        // 手机号登录
        phoneBtn.addTarget(self, action: #selector(phone_regiest), for: .touchUpInside)
    }
    
    // 手机号登录
    @objc private func phone_regiest(){
        
        push(NGPhoneRegVC())
    }
    
    /// 立即注册
    @objc func regiestClick(){
        
        if textField1.check() || textField2.check(){
            return
        }
        
        if (NGNet.shared.config.is_user_protocol == "1" && pro_view?.isSelected ?? false == false) {
            Totas.show(pro_view?.msg ?? "", .info)
            return
        }
        
        view.endEditing(true)
        
        let username = textField1.text ?? ""
        let password = textField2.text ?? ""
        
        NGNet.apiFastReg(username, password) {[weak self] flag, response, msg ,dict in
            if flag {
                Totas.show("注册成功", .success) {
                    // 登录
                    self?.login(username, password)
                    // 上报注册成功
                    NGEvent.upload(.register_success)
                }
            } else {
                Totas.show(msg, .fail)
            }
        }
    }
}
