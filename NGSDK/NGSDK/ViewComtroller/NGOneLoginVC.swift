//
//  NGOneLoginVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/14.
//

import UIKit
import OneLoginSDK

class NGOneLoginVC: NGViewController {
    
    var phone: String?
    private let pro_view = NGProtocol.init(frame: CGRectZero)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NGEvent.upload(.geelogin_show)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backBtn.removeFromSuperview()
        
        let label = NGLabel.label("运营商")
        
        let phoneLabel = NGLabel.label("本机号码")
        phoneLabel.font = UIFont.boldSystemFont(ofSize: 20)
        phoneLabel.textColor = .darkGray
        
        let btn1 = NGButton.button("本机号码一键登录")
        
        let btn2 = NGButton.button("其他手机号码登录")
        btn2.setBackgroundImage(UIImage.image("icon_按钮_normal"), for: .normal)
        
        let small_btn1 = NGButton.smallButton("账号登录")
        let small_btn2 = NGButton.smallButton("快速注册")
        
        small_btn1.contentHorizontalAlignment = .left
        small_btn2.contentHorizontalAlignment = .right
        
        view.addSubview(label)
        view.addSubview(phoneLabel)
        view.addSubview(btn1)
        view.addSubview(btn2)
        view.addSubview(small_btn1)
        view.addSubview(small_btn2)
        
        label.snp.makeConstraints { make in
            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.top.equalTo(imgView.snp.bottom).offset(20)
            make.height.equalTo(30)
        }
        
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.top.equalTo(label.snp.bottom)
            make.height.equalTo(50)
        }
        
        let height = button_height + 3
        btn1.snp.makeConstraints { make in
            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)
            make.top.equalTo(phoneLabel.snp.bottom)
            make.height.equalTo(height)
        }
        
        btn2.snp.makeConstraints { make in
            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)
            make.top.equalTo(btn1.snp.bottom).offset(8)
            make.height.equalTo(height)
        }
        
        small_btn1.snp.makeConstraints { make in
            make.top.equalTo(btn2.snp.bottom).offset(8)
            make.height.equalTo(image_size)
            make.left.equalTo(button_horizontal)
            make.width.equalTo(small_btn2.snp.width)
        }
        
        small_btn2.snp.makeConstraints { make in
            
            make.top.equalTo(btn2.snp.bottom).offset(8)
            make.height.equalTo(image_size)
            make.right.equalTo(-button_horizontal)
            make.left.equalTo(small_btn1.snp.right).offset(5)
        }
        
        // 一键登录
        btn1.addTarget(self, action: #selector(one_login), for: .touchUpInside)
        btn2.addTarget(self, action: #selector(phone_login), for: .touchUpInside)
        
        small_btn1.addTarget(self, action: #selector(account_login), for: .touchUpInside)
        small_btn2.addTarget(self, action: #selector(quick_regiest), for: .touchUpInside)
        
        label.text = pro_view.logan
        phoneLabel.text = phone
        
        view.addSubview(pro_view)
        pro_view.snp.makeConstraints { make in
            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.top.equalTo(small_btn1.snp.bottom).offset(3)
            make.height.equalTo(49)
        }
        
        let is_protocol = (NGNet.shared.config.is_user_protocol == "1")
        if (is_protocol){
            pro_view.update(mode: .xmyys)
        } else {
            pro_view.update(mode: .yys)
        }
        
        #if DEBUG
        label.text = "天翼账号提供认证服务"
        phoneLabel.text = "15072366160"
        #else
        
        #endif
    
        let member = Member.first()
        if member != nil {
            account_login()
        }
    }
    
    // 其他手机号登录
    @objc private func phone_login(){
        
        push(NGPhoneLoginVC())
    }
    
    // 账号登录
    @objc private func account_login(){
        
        push(NGAccountVC())
    }
    
    // 快速注册
    @objc private func quick_regiest(){
        
        push(NGFastRegVC())
    }
    
    // 关闭界面
    override func backBtnAction() {
        dismiss(animated: true)
    }
    
    /// 一键登录
    @objc private func one_login(){
        
        if (pro_view.isSelected == false) {
            Totas.show(pro_view.msg, .info)
            return
        }
        
        Totas.show()
        OneLoginPro.requestToken { [weak self] reslut in
            Totas.dismiss()
            self?.login(info: reslut as? [String: Any])
        }
    }
    
    private func login(info: [String: Any]?) {
        
        let process_id = info?["processID"] as? String ?? ""
        let token      = info?["token"] as? String ?? ""
        let authcode   = info?["authcode"] as? String ?? ""
        
        NGNet.apiOneLogin(process_id: process_id, token: token, authcode: authcode) { [weak self] flag, response, msg, dict in
            
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
