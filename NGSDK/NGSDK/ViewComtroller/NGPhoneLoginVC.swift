//
//  NGPhoneLoginVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/14.
//

import UIKit

class NGPhoneLoginVC: NGViewController {
    
    var isRoot = false
    
    private let textField1 = NGTextField(.phone)
    private let textField2 = NGTextField(.code)
    private let btn = NGButton.button("登录")
    private var sendBtn: UIButton!
    private var bottomView: UIView!
    var pro_view: NGProtocol?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField1.text = UserDefaults.standard.object(forKey: "phone_login_cache") as? String ?? ""
        NGEvent.upload(.phonelogin_show)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("手机登录")
        
        view.addSubview(textField1)
        view.addSubview(textField2)
        
        btn.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
        view.addSubview(btn)
        
        sendBtn = textField2.addSendCodeBtn()
        sendBtn.addTarget(self, action: #selector(sendCode(_:)), for: .touchUpInside)
        
        if isRoot {
            backBtn.removeFromSuperview()
            
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
                
                make.top.equalTo(textField2.snp.bottom).offset(20)
                make.height.equalTo(button_height)
                make.right.equalTo(-button_horizontal)
                make.left.equalTo(button_horizontal)
            }
            
            let small_btn1 = NGButton.smallButton("账号登录")
            let small_btn2 = NGButton.smallButton("快速注册")
            
            view.addSubview(small_btn1)
            view.addSubview(small_btn2)
            
            small_btn1.contentHorizontalAlignment = .left
            small_btn2.contentHorizontalAlignment = .right
            
            small_btn1.snp.makeConstraints { make in
                make.top.equalTo(btn.snp.bottom).offset(8)
                make.height.equalTo(image_size)
                make.left.equalTo(button_horizontal)
                make.width.equalTo(small_btn2.snp.width)
            }
            
            small_btn2.snp.makeConstraints { make in
                
                make.top.equalTo(btn.snp.bottom).offset(8)
                make.height.equalTo(image_size)
                make.right.equalTo(-button_horizontal)
                make.left.equalTo(small_btn1.snp.right).offset(5)
            }
            
            // 账号登录
            small_btn1.addTarget(self, action: #selector(account_login), for: .touchUpInside)
            // 快速注册
            small_btn2.addTarget(self, action: #selector(quick_regiest), for: .touchUpInside)
            
            bottomView = small_btn1
        } else {
            
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
                
                make.top.equalTo(textField2.snp.bottom).offset(25)
                make.height.equalTo(button_height)
                make.right.equalTo(-button_horizontal)
                make.left.equalTo(button_horizontal)
            }
            
            bottomView = btn
        }
        
        // 位置设置
        let is_protocol = (NGNet.shared.config.is_user_protocol == "1")
        if (is_protocol == true) {
            
            pro_view = NGProtocol.init(frame: CGRectZero)
            view.addSubview(pro_view!)
            
            pro_view!.snp.makeConstraints { make in
                make.left.equalTo(textfield_horizontal)
                make.right.equalTo(-textfield_horizontal)
                make.top.equalTo(bottomView.snp.bottom).offset(8)
                make.bottom.equalTo(-8)
            }

        }
        
        let member = Member.first()
        if member != nil && self.isRoot {
            push(NGAccountVC())
        }
    }
    
    // 账号登录
    @objc private func account_login(){
        
        push(NGAccountVC())
    }
    
    // 快速注册
    @objc private func quick_regiest(){
        
        push(NGFastRegVC())
    }
    
    /// 发送验证码
    @objc private func sendCode(_ btn: UIButton){
        sendCode(btn, textField1, "6")
    }
    
    @objc private func btnAction(){
        if textField1.check() || textField2.check(){
            return
        }
        
        let is_protocol = (NGNet.shared.config.is_user_protocol == "1")
        if (is_protocol && pro_view?.isSelected == false) {
            Totas.show(pro_view?.msg ?? "", .info)
            return
        }
        
        if (checkCodeTime()) {
            return;
        }
        
        view.endEditing(true)
        
        let phone = textField1.text ?? ""
        let code = textField2.text ?? ""
        NGNet.apiPhoneLogin(phone, code) { [weak self] flag, response, msg ,dict in
            if flag {
                
                let data = response as? [String: Any]
                NGNet.shared.user.trueNameSwitch = data?["trueNameSwitch"] as? String
                
                NGNet.shared.user.wx_appid = data?["wx_appid"] as? String
                NGNet.shared.user.birthday = data?["birthday"] as? String
                NGNet.shared.user.is_smrz  = data?["is_smrz"] as? Int
                
                NGNet.shared.user.profile = data?["profile"] as? String
                NGNet.shared.user.qqappid = data?["qqappid"] as? String
                NGNet.shared.user.userSex = data?["userSex"] as? Int
                
                NGNet.shared.user.trueName        = data?["trueName"] as? String
                NGNet.shared.user.isBindMobile    = data?["isBindMobile"] as? Int
                NGNet.shared.user.is_show_binding = data?["is_show_binding"] as? String
                
                NGNet.shared.user.drurl     = data?["drurl"] as? Int
                NGNet.shared.user.isOldUser = data?["isOldUser"] as? Int
                NGNet.shared.user.sid       = data?["sid"] as? String
                
                NGNet.shared.user.idCard    = data?["idCard"] as? String
                NGNet.shared.user.buoyState = data?["buoyState"] as? String
                NGNet.shared.user.uid       = data?["uid"] as? String
                
                NGNet.shared.user.mobile    = data?["mobile"] as? String
                NGNet.shared.user.age       = data?["age"] as? String
                NGNet.shared.user.nick_name = data?["nick_name"] as? String
                
                NGNet.shared.user.isShare   = data?["isShare"] as? Int
                NGNet.shared.user.adult     = data?["adult"] as? Int
                NGNet.shared.user.user_name = data?["user_name"] as? String
                
                NGNet.shared.user.password = data?["userPass"] as? String
                
                if NGNet.shared.user.isOldUser != 1 {
                    NGEvent.upload(.register_success)
                }
                
                Totas.show("登录成功", .success) {
                    self?.dismiss(animated: true, completion: {
                        NGSDK.shared.checkBindPhone() // 检测绑定手机
                    })
                }
                
            } else {
                
                let sta = dict?["state"]
                let code = sta?["code"] as? Int ?? 0
                
                if code == 2 {
                    
                    let info = dict?["data"]
                    Totas.show("老用户请重置密码后登录") {
                        let vc = NGResetVC()
                        vc.username = info?["username"] as? String
                        vc.token = info?["token"] as? String
                        self?.push(vc)
                    }
                } else {
                    Totas.show(msg, .fail) {
                        NGSDK.shared.sdkLoginResult(false)
                    }
                }
            }
        }
    }
    
}
