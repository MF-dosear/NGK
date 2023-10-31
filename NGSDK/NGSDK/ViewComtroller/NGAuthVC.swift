//
//  NGAuthVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/23.
//

import UIKit

class NGAuth: NGViewController {
    
    private let textField1 = NGTextField(.name)
    private let textField2 = NGTextField(.idCard)
    private let btn = NGButton.button("确定")
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NGEvent.upload(.realname_show)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("实名认证")
        
        if (NGNet.shared.config.smrz_show_close_button == "1") {
            setCloseBtn()
        } else {// 强制实名认证
            backBtn.removeFromSuperview()
        }
        
        view.addSubview(textField1)
        view.addSubview(textField2)
        view.addSubview(btn)
        
        let label = UILabel()
        label.text = "根据国家规定，游戏用户需进行实名认证!"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = tips_title_color
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        
        let label2 = UILabel()
        label2.text = "我们承诺将严格保护您的个人信息，不会对外泄漏!"
        label2.font = UIFont.systemFont(ofSize: 14)
        label2.textColor = tips_title_color
        label2.textAlignment = .center
        label2.adjustsFontSizeToFitWidth = true
        view.addSubview(label2)
        
        let label3 = UILabel()
        label3.text = "-----完成实名认证即可获得认证奖励-----\n（游戏内通过邮件发放）"
        label3.font = UIFont.systemFont(ofSize: 14)
        label3.textColor = UIColor.systemOrange
        label3.textAlignment = .center
        label3.numberOfLines = 0
        label3.adjustsFontSizeToFitWidth = true
        view.addSubview(label3)
        
        let imgView1 = UIImageView.init(image: UIImage.image("橙色武器宝箱@2x"))
        imgView1.contentMode = .scaleAspectFit
        view.addSubview(imgView1)
        
        let imgView2 = UIImageView.init(image: UIImage.image("金格萨贝鲁@2x"))
        imgView2.contentMode = .scaleAspectFit
        view.addSubview(imgView2)
        
        label.snp.makeConstraints { make in
            
            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)
            make.height.equalTo(30)
            make.top.equalTo(imgView.snp.bottom).offset(45)
        }
        
        textField1.snp.makeConstraints { make in

            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(label.snp.bottom)
        }

        textField2.snp.makeConstraints { make in

            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(textField1.snp.bottom).offset(8)
        }

        label2.snp.makeConstraints { make in

            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)
            make.height.equalTo(30)
            make.top.equalTo(textField2.snp.bottom)
        }

        btn.snp.makeConstraints { make in

            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)

            make.height.equalTo(button_height)
            make.top.equalTo(label2.snp.bottom).offset(5)
        }
        
        label3.snp.makeConstraints { make in

            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)
            make.height.equalTo(45)
            make.top.equalTo(btn.snp.bottom)
        }
        
        imgView1.snp.makeConstraints { make in

            make.left.equalTo(button_horizontal)
            make.right.equalTo(imgView2.snp.left).offset(-8)
            make.top.equalTo(label3.snp.bottom)
            make.bottom.equalTo(-15)
        }
        
        imgView2.snp.makeConstraints { make in

            make.right.equalTo(-button_horizontal)
            make.width.equalTo(imgView1.snp.width)
            make.top.equalTo(label3.snp.bottom)
            make.bottom.equalTo(-15)
        }
        
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        
//        label.backgroundColor = UIColor.systemRed
    }
    
    /// 退出
    override func backBtnAction() {
        dismiss(animated: true) {
            NGSDK.shared.sdkLoginResult(true)
        }
    }
    
    /// 立即实名认证
    @objc private func btnAction(){
        if textField1.check() || textField2.check(){
            return
        }
        
        view.endEditing(true)
        
        let name = textField1.text ?? ""
        let idCard = textField2.text ?? ""
        
        NGEvent.upload(.realname_commit)
        
        NGNet.apiAuth(name, idCard) {[weak self] flag, response, msg ,dict in
            if flag {
                
                let data = response as? [String: Any]
                let is_smrz = data?["is_smrz"] as? Int ?? 0
                NGNet.shared.user.is_smrz = is_smrz
                let message = data?["msg"] as? String ?? ""
                
                if is_smrz == 1 {
                    
                    Totas.show("认证成功", .success) {
                        self?.backBtnAction()
                    }
                    
                    NGEvent.upload(.realname_success)
                } else {
                    Totas.show(message, .fail)
                }
            } else {
                Totas.show(msg, .fail)
            }
        }
    }
}
