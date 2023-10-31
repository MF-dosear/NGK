//
//  NGAccountVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/21.
//

import UIKit

class NGAccountVC: NGViewController {
    
    var isRemoveBack = false
    let textField1 = NGTextField.init(.command)
    let textField2 = NGTextField.init(.password)
    let btn = NGButton.button("登录")
    var userBtn: UIButton!
    let tableView = NGTableView(frame: .zero, style: .grouped)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let member = Member.first()
        textField1.text = member?.username
        textField2.text = member?.password
        
        NGEvent.upload(.accountlogin_show)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgView.image = UIImage.image("账号登录")
        
        if isRemoveBack {
            backBtn.removeFromSuperview()
        }
        
        view.addSubview(textField1)
        view.addSubview(textField2)
        view.addSubview(btn)
        btn.addTarget(self, action: #selector(loginClick), for: .touchUpInside)
        
        let forgetBtn = NGButton.smallButton("忘记密码")
        view.addSubview(forgetBtn)
        
        textField1.snp.makeConstraints { make in
            make.left.equalTo(textfield_horizontal)
            make.right.equalTo(-textfield_horizontal)
            make.height.equalTo(textfield_height)
            make.top.equalTo(imgView.snp.bottom).offset(60)
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
            make.top.equalTo(textField2.snp.bottom).offset(25)
        }
        
        forgetBtn.snp.makeConstraints { make in
            make.top.equalTo(btn.snp.bottom).offset(8)
            make.height.equalTo(samll_button_height)
            make.right.equalTo(-textfield_horizontal)
            make.width.equalTo(80)
        }
        
        userBtn = textField1.addUsersBtn()
        userBtn.addTarget(self, action: #selector(showClick), for: .touchUpInside)
        
        tableView.alpha = 0
        tableView.block = {[weak self] member in
            self?.textField1.text = member?.username
            self?.textField2.text = member?.password
            self?.showClick()
        }
        
        forgetBtn.addTarget(self, action: #selector(forgetAction), for: .touchUpInside)
    }
    
    // 其他手机号登录
    @objc private func forgetAction(){
        
        push(NGFindVC())
    }
    
    // 立即登录
    @objc func loginClick(){
        if textField1.check() || textField2.check(){
            return
        }
        
        view.endEditing(true)
        
        let username = textField1.text ?? ""
        let password = textField2.text ?? ""
        
        login(username, password)
    }
    
    /// 展示更多用户
    @objc func showClick(){
        
        userBtn.isSelected = !userBtn.isSelected
        if userBtn.isSelected {
            
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.left.equalTo(textfield_horizontal)
                make.right.equalTo(-textfield_horizontal)
                make.top.equalTo(textField1.snp.bottom).offset(2)
                make.height.equalTo(176)
            }
            
            // 展示
            UIView.animate(withDuration: 0.3) {
                self.tableView.alpha = 1
            }
        } else {
            // 收起
            UIView.animate(withDuration: 0.3) {
                self.tableView.alpha = 0
            } completion: { flag in
                self.tableView.removeFromSuperview()
            }
        }
    }
}

