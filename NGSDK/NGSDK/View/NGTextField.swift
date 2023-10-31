//
//  NGTextField.swift
//  NGSDK
//
//  Created by Paul on 2023/2/15.
//

import UIKit

enum NGTextFieldMode {
    case command
    case username
    case phone
    case password
    case code
    case name
    case idCard
    
    func hasPrefix() -> String{
        switch self {
            case .command:  return "手机号/用户名"
            case .username: return "用户名"
            case .phone:    return "手机号"
            case .password: return "密码"
            case .code:     return "验证码"
            case .name:     return "姓名"
            case .idCard:   return "身份证号"
        }
    }
    
    func placeholder() -> String{
        switch self {
            case .command:  return "请输入用户名"
            case .username: return "请输入账号"
            case .phone:    return "请输入手机号"
            case .password: return "请输入密码"
            case .code:     return "请输入验证码"
            case .name:     return "请输入真实姓名"
            case .idCard:   return "请输入身份证号"
        }
    }
    
    func imgName() -> String{
        switch self {
            case .command:  return "icon_用户"
            case .username: return "icon_用户"
            case .phone:    return "icon_手机号"
            case .password: return "icon_密码"
            case .code:     return "icon_短信"
            case .name:     return "icon_用户"
            case .idCard:   return "icon_身份证"
        }
    }
    
    func keyboardType() -> UIKeyboardType{
        switch self {
        case .phone:  return .numberPad
        case .code:   return .numberPad
        case .name:   return .default
        default :     return .asciiCapable
        }
    }
}


class NGTextField: UITextField,UITextFieldDelegate {
    
    var mode: NGTextFieldMode!
    
    init(_ mode: NGTextFieldMode) {
        super.init(frame: CGRectZero)
        
        self.mode = mode
        
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: textfield_height, height: textfield_height))
        
        let imgView = UIImageView.init(image: UIImage.image(mode.imgName()))
        imgView.contentMode = .scaleAspectFit
        imgView.frame = CGRect(x: 0, y: 0, width: image_size, height: image_size)
        imgView.center = CGPoint(x: 20, y: textfield_height / 2)
        leftView.addSubview(imgView)
        
        self.leftView = leftView
        self.leftViewMode  = .always
        
        let font = UIFont.systemFont(ofSize: 16)
        
        let attributes: [NSAttributedString.Key : Any] = [
            .font : font,
            .foregroundColor : textField_placeholder_color
        ]
        
        self.attributedPlaceholder = NSAttributedString(string: mode.placeholder() ,attributes: attributes)
        self.font = font
        self.adjustsFontSizeToFitWidth = true
        self.textColor = textField_title_color
        
        self.clearButtonMode = .whileEditing
        self.keyboardType = mode.keyboardType()
        self.delegate = self
        
        if mode == .password {
            /// 添加眼睛
            addEyeBtn()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 添加发送验证码按钮
    /// - Returns: 返回按钮
    func addSendCodeBtn() -> UIButton{
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: textfield_height))
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 90, height: 26)
        btn.center = CGPoint(x: 40, y: textfield_height / 2)
        btn.setBackgroundImage(UIImage.image("icon_验证码"), for: .normal)
        btn.setTitleColor(send_title_color, for: .normal)
        btn.setTitle("获取验证码", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        rightView.addSubview(btn)
        self.rightView = rightView
        self.rightViewMode = .always
        return btn
    }
    
    /// 添加切换用户按钮
    /// - Returns: 返回按钮
    func addUsersBtn() -> UIButton{
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: textfield_height, height: textfield_height))
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: image_size, height: image_size)
        btn.center = rightView.center
        btn.setImage(UIImage.image("icon_箭头上"), for: .normal)
        btn.setImage(UIImage.image("icon_箭头下"), for: .selected)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.setTitleColor(send_title_color, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        rightView.addSubview(btn)
        self.rightView = rightView
        self.rightViewMode = .always
        return btn
    }
    
    /// 添加眼睛查看密码按钮
    /// - Returns: 返回按钮
    func addEyeBtn(){
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: textfield_height, height: textfield_height))
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: image_size, height: image_size)
        btn.center = rightView.center
        btn.setImage(UIImage.image("icon_密码关"), for: .normal)
        btn.setImage(UIImage.image("icon_密码开"), for: .selected)
        btn.imageView?.contentMode = .scaleAspectFit
        rightView.addSubview(btn)
        self.rightView = rightView
        self.rightViewMode = .always
        self.isSecureTextEntry = true
        
        btn.addTarget(self, action: #selector(passwordAction(_:)), for: .touchUpInside)
    }
    
    @objc func passwordAction(_ btn: UIButton){
        
        isSecureTextEntry = btn.isSelected;
        btn.isSelected = !btn.isSelected;
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIImage.image("icon_输入框背景")?.draw(in: rect)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty{
            return true
        }
        
        if let text = textField.text {
            
            let str = NSString(string: text).replacingCharacters(in: range, with: string)
            
            /// 验证码
            if mode == .code && str.count > 6 {
                return false
            }
            
            /// 手机号
            if mode == .phone && str.count > 11 {
                return false
            }
            
            /// 只输入数字
            if mode == .phone || mode == .code{
                return str.isNumber()
            }
        }

        return true;
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true;
    }
    
    func check() -> Bool{
        
        let text = self.text ?? "";
        
        if (text.isEmpty) {
            let msg = "请输入\(self.mode.hasPrefix())"
            Totas.show(msg)
            return true
        }
        
        if text.contains(" ") {
            let msg = "\(self.mode.hasPrefix())中不能包含空格"
            Totas.show(msg)
            return true
        }
        
        if self.mode == .phone && text.count != 11{
            Totas.show("手机号格式不正确")
            return true;
        }
        
        if (self.mode == .password) {
            
            if text.count < 6 {
                Totas.show("密码不能少于6位")
                return true;
            }
            
            if text.count > 16 {
                Totas.show("密码不能大于16位")
                return true;
            }
            
            if text.contains(" ") {
                Totas.show("密码中不能包含空格")
                return true;
            }
        }
        
        return false
    }

    deinit{
        print("\(NSStringFromClass(self.classForCoder))被销毁")
    }
}
