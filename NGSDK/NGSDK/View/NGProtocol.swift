//
//  NGProtocol.swift
//  NGSDK
//
//  Created by Paul on 2023/2/15.
//

import UIKit
import OneLoginSDK

enum NGProMode {
    case xm
    case yys
    case xmyys
}

class NGProtocol: UIView, UITextViewDelegate{
    
    var isSelected = false
    var msg: String = ""
    var logan: String = "运营商"
    private let textView = UITextView()
    
    private var url = ""
    private var title = "运营商协议"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.image("icon_选择_true"), for: .selected)
        btn.setImage(UIImage.image("icon_选择_flase"), for: .normal)
        btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
        self.addSubview(btn)
        
        textView.delegate = self
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.adjustsFontForContentSizeCategory = true
        self.addSubview(textView)

        btn.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(image_size)
        }
        
        textView.snp.makeConstraints { make in
            make.right.top.bottom.equalTo(0)
            make.left.equalTo(btn.snp.right).offset(5)
        }
        
        let info = OneLoginPro.currentNetworkInfo()
        
        if info?.carrierName == "CM" {
            // 移动
            url   = OLCMTermLink
            logan = OLCMSlogan
            title = OLCMTermTitle
        } else if info?.carrierName == "CU" {
            // 联通
            url   = OLCUTermLink
            logan = OLCUSlogan
            title = OLCUTermTitle
        } else if info?.carrierName == "CT" {
            // 电信
            url   = OLCTTermLink
            logan = OLCTSlogan
            title = OLCTTermTitle
        }
        
        update(mode: .xm)
    }
    
    func update(mode:NGProMode){
        if mode == .yys{
            let ope = "《\(title)》"
            msg = "请阅读并同意\(ope)"
            let text = NSString(string: msg)
            let att = NSMutableAttributedString(string: text as String)
            let ope_range = text.range(of: ope)
            att.addAttribute(.link, value: "ope://", range: ope_range)
            
            att.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: att.length))
            textView.attributedText = att
        } else if mode == .xmyys {
            let pro = "《用户协议》"
            let pri = "《隐私条款》"
            let ope = "《\(title)》"
            msg = "请阅读并同意\(pro)、\(pri)、\(ope)"
            let text = NSString(string: msg)
            
            let att = NSMutableAttributedString(string: text as String)
            
            let pro_range = text.range(of: pro)
            att.addAttribute(.link, value: "pro://", range: pro_range)
            
            let pri_range = text.range(of: pri)
            att.addAttribute(.link, value: "pri://", range: pri_range)
            
            let ope_range = text.range(of: ope)
            att.addAttribute(.link, value: "ope://", range: ope_range)
            
            att.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: att.length))
            textView.attributedText = att
        } else {
            let pro = "《用户协议》"
            let pri = "《隐私条款》"
            msg = "请阅读并同意\(pro)、\(pri)"
            let text = NSString(string: msg)
            
            let att = NSMutableAttributedString(string: text as String)
            
            let pro_range = text.range(of: pro)
            att.addAttribute(.link, value: "pro://", range: pro_range)
            
            let pri_range = text.range(of: pri)
            att.addAttribute(.link, value: "pri://", range: pri_range)
            
            att.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: att.length))
            textView.attributedText = att
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
        if URL.scheme == "pro" {
            protocolAction()
            return false
        } else if URL.scheme == "pri" {
            privateAction()
            return false
        } else if URL.scheme == "ope" {
            operatorAction()
            return false
        }
        
        return true
    }
    
    @objc private func btnAction(_ btn: UIButton){
        
        isSelected = !isSelected
        btn.isSelected = isSelected
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("\(NSStringFromClass(self.classForCoder))被销毁")
    }
    
    /// 隐私条款
    func privateAction(){
        NGSDK.sdkOpenUrl(url: NGNet.shared.config.user_private)
    }
    
    /// 协议
    func protocolAction(){
        NGSDK.sdkOpenUrl(url: NGNet.shared.config.user_protocol)
    }
    
    /// 运营商协议
    func operatorAction(){
        NGSDK.sdkOpenUrl(url: url)
    }
}
