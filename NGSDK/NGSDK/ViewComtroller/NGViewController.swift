//
//  NGViewController.swift
//  NGSDK
//
//  Created by Paul on 2023/2/14.
//

import UIKit

class NGSDKViewController: UIViewController {
    
    deinit{
        print("\(NSStringFromClass(self.classForCoder))被销毁")
    }
}

class NGViewController: NGSDKViewController {
    
    var imgView: UIImageView!
    var backBtn: UIButton!
    
    let btn_sp = 5
    let btn_top = 10
    
    var time: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        
        let imageView = UIImageView.init(image: UIImage.image("icon_背景"))
        view.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imgView = UIImageView.init(image: UIImage.image("一键登录"))
        imgView.contentMode = .scaleAspectFit
        view.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(35)
            make.width.equalTo(150)
            make.top.equalTo(5)
        }
        
        backBtn = UIButton.init(type: .custom)
        backBtn.setImage(UIImage.image("icon_返回"), for: .normal)
        view.addSubview(backBtn)
        
        backBtn.snp.makeConstraints { make in
            make.left.equalTo(btn_sp)
            make.top.equalTo(btn_top)
            make.height.equalTo(35)
            make.width.equalTo(40)
        }
        
        backBtn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
    }
    
    /// 退出
    @objc func backBtnAction(){
        pop()
    }
    
    func setCloseBtn(){
        
        backBtn.setImage(UIImage.image("icon_关闭"), for: .normal)
        
        backBtn.snp.remakeConstraints { make in
            make.right.equalTo(-btn_sp)
            make.top.equalTo(btn_top)
            make.height.equalTo(35)
            make.width.equalTo(40)
        }
    }
    
    /// 登录
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    func login(_ username: String, _ password: String){
        NGNet.apiLogin(username, password) { [weak self] flag, response, msg ,dict in
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
                
                NGNet.shared.user.password = password
                
                Totas.show("登录成功", .success) {
                    self?.dismiss(animated: true, completion: {
                        // 检查是否绑定手机号
                        NGSDK.shared.checkBindPhone()
                    })
                }
                
            } else {
                Totas.show(msg, .fail) {
                    NGSDK.shared.sdkLoginResult(false)
                }
            }
        }
    }
    
    /// 发送验证码
    func sendCode(_ btn: UIButton, _ textField: NGTextField, _ smsType: String){
        if textField.check(){
            return
        }
        
        let phone = textField.text ?? ""
        NGNet.apiSendCode(phone, smsType) { [weak self] flag, response, msg ,dict in
            
            if flag {
                let data = response as? [String: Any]
                self?.time = data?["times"] as? Int ?? 0
                Totas.show("发送验证码成功", .success) {
                    
                    btn.sendCode(60, "获取验证码", "秒")
                    textField.becomeFirstResponder()
                }
            } else {
                Totas.show(msg, .fail)
            }
        }
    }
    
    func checkCodeTime() -> Bool{
        let time_now = Int(Date().timeIntervalSince1970)
        return time != 0 && time < time_now
    }
}
