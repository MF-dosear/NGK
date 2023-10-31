//
//  NGBindVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/22.
//

import UIKit

class NGBindVC: NGViewController {
    
    var isDismiss: Bool = false
    
    private let textField1 = NGTextField(.phone)
    private let textField2 = NGTextField(.code)
    private let btn = NGButton.button("确定")
    private var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("绑定手机")
        setCloseBtn()
        
        sendBtn = textField2.addSendCodeBtn()
        
        view.addSubview(textField1)
        view.addSubview(textField2)
        view.addSubview(btn)
        
        let label = UILabel()
        label.text = "温馨提示！\n1、手机仅作为身份验证，不收取任何费用，请放心使用！\n2、本公司承诺保障您的隐私，不会泄露您的手机号！"
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = tips_title_color
        label.numberOfLines = 0
        view.addSubview(label)
        
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
        
        btn.snp.makeConstraints { make in
            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)
            make.height.equalTo(button_height)
            make.top.equalTo(textField2.snp.bottom).offset(12)
        }
        
        label.snp.makeConstraints { make in
            
            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.top.equalTo(btn.snp.bottom).offset(8)
            make.bottom.equalTo(-16)
        }
        
        sendBtn.addTarget(self, action: #selector(sendCode(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
    }
    
    // 退出
    override func backBtnAction() {
        view.endEditing(true)
        dismiss(animated: false) {
            if self.isDismiss == false {
                // 实名认证
                NGSDK.shared.checkAuth()
            }
        }
    }
    
    /// 发送验证码
    @objc private func sendCode(_ btn: UIButton){
        sendCode(btn, textField1, "0")
    }
    
    /// 立即绑定
    @objc private func btnAction() {
        if textField1.check() || textField2.check(){
            return
        }
        
        view.endEditing(true)
        
        let phone = textField1.text ?? ""
        let code = textField2.text ?? ""
        
        NGNet.apiBindPhone(phone, code) { [weak self] flag, response, msg ,dict in
            if flag {
                
                Totas.show("绑定成功", .success) {
                    self?.backBtnAction()
                }
            } else {
                Totas.show(msg, .fail)
            }
        }
    }
}
