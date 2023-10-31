//
//  NGApiVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/28.
//

import UIKit
import WebKit

enum NGApiVCMode: String {
    case account = "账户"
    case share   = "分享"
    case pay     = "支付"
}

class NGApiVC: NGSDKViewController, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
    
    private var url = ""
    private var mode = NGApiVCMode.account
    
    private var webView: WKWebView!
    
    private let funcs = [
        "closeWeb",
        "openSafari",
        "passValue",
        "copyGame",
        "toShareU",
        "saveRedDot",
        "getRedDot",
        "getAgeBirth"
    ]
    
    init(url: String, mode: NGApiVCMode) {

        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
        
        self.title = mode.rawValue
        
        self.url = url
        self.mode = mode
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mode == .share {
            self.webView.isOpaque = false
            self.webView.scrollView.isScrollEnabled = false
        }

        guard let api_url = URL(string: url) else {
            print("链接错误: \(String(describing: url))")
            return
        }

        let request = URLRequest(url: api_url)
        webView.load(request)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        
        let userContentController = WKUserContentController()
        
        for func_name in funcs {
            userContentController.add(self, name: func_name)
        }
        
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController

        // 进行偏好设置
        let preferences = WKPreferences()
        // 不通过用户交互，是否可以打开窗口
        preferences.javaScriptCanOpenWindowsAutomatically = true
        // 是否支持JavaScript
        preferences.javaScriptEnabled = true
        preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.preferences = preferences
        config.allowsInlineMediaPlayback = true

        webView = WKWebView(frame: CGRectZero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

//        webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(webView)
        
        if mode == .account {
            webView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(background_horizontal)
                make.right.equalToSuperview().offset(-background_horizontal)
                make.centerY.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.5)
            }
        } else {
            webView.snp.makeConstraints { make in
                make.edges.equalTo(UIEdgeInsets.zero)
            }
        }
        
        if mode == .pay {
            
            navigationController?.navigationBar.isHidden = false
            
            let closeItem = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(backAction))
            navigationItem.rightBarButtonItem = closeItem
        }
    }
    
    @objc func backAction(){

        dismiss(animated: true) {
            
            for func_name in self.funcs {
                self.webView.configuration.userContentController.removeScriptMessageHandler(forName: func_name)
            }

            if self.mode == .pay {
                self.checkOrder()
            }
        }
    }

    func params(url: String) -> [String:String]?{

        if url.isEmpty {
            return nil
        }

        let list = url.components(separatedBy: "&")

        var dict = [String:String]()
        for key_value in list {

            let k_v_s = key_value.components(separatedBy: "=")
            dict[k_v_s[0]] = k_v_s[1]
        }
        return dict
    }
    
    /// MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        //可以通过navigationAction.navigationType 获取跳转类型，如新链接、后退等
        let url = navigationAction.request.url
        let scheme = url?.scheme ?? ""
        //判断URL是否符合自定义的URL Scheme
        if scheme == "http" || scheme == "https" {

            // 重置密码
            let dict = params(url: url?.query ?? "")

            let dod = dict?["do"] ?? ""
            if dod == "pwd" {
                let password = dict?["pwd"] ?? ""
                let name = dict?["userName"] ?? ""
                let state = dict?["state"] ?? ""
                let msg = dict?["msg"] ?? ""

                reset(password: password, name: name, state: state, msg: msg)
            }
            
            decisionHandler(.allow)
         } else {
            UIApplication.shared.open(url!, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly : false])
            decisionHandler(.cancel)
         }
    }
    
    func reset(password: String, name: String, state: String, msg: String){

        if state == "1" {

            if name.isEmpty || password.isEmpty {
                Totas.show("修改密码失败", .info)
                return
            }

            // 存用户
            NGNet.shared.user.user_name = name
            NGNet.shared.user.password = password

            // 删除
            var member = Member.seleted(name)
            member?.delete()

            // 添加新的
            member = Member()
            member?.username = NGNet.shared.user.user_name
            member?.password = NGNet.shared.user.password
            member?.insert()
        }

        if msg.isEmpty == false {
            guard let text = msg.removingPercentEncoding else {
                return print("msg为空")
            }
            Totas.show(text, .info)
        }
    }

    // 分享
    func share(_ params: [String: Any]?){

        let app = params?["app"] as? String ?? ""

        let mode:NGShareMode = app == "share1" ? .QQ : .wechat

        let text = params?["text"] as? String ?? ""
        let title = params?["title"] as? String ?? ""
        let url = params?["url"] as? String ?? ""
        let icon = params?["icon"] as? String ?? ""

        DispatchQueue.global().async {

            guard let image_url = URL(string: icon) else { return
                NGSDK.sdkShare(mode: mode, title: title, text: text, url: url)
            }

            guard let data = try? Data(contentsOf: image_url) else { return
                NGSDK.sdkShare(mode: mode, title: title, text: text, url: url)
            }

            DispatchQueue.main.async {

                let image = UIImage(data: data)
                NGSDK.sdkShare(mode: mode, title: title, text: text, url: url, previewImage: image)
            }
        }
    }
                                                      
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if message.name == "closeWeb" {
            // 关闭
            backAction()
        } else if message.name == "openSafari" {

            // 浏览器打开
            guard let url = URL(string: message.body as? String ?? "") else {
                print("message.body 链接错误")
                return
            }

            UIApplication.shared.open(url)
        } else if message.name == "passValue" {
            // 提示框
            guard let text = message.body as? String else {
                print("message.body 提示错误")
                return
            }
            Totas.show(text, .info)
        } else if message.name == "copyGame" {
            // 提示框
            guard let text = message.body as? String else {
                print("message.body copy错误")
                return
            }
            UIPasteboard.general.string = text
            Totas.show("复制成功", .success)
        } else if message.name == "toShareU" {
            // 分享
            guard let text = message.body as? String else {
                print("message.body 分享错误")
                return
            }

            let dict = text.dictionaryValue()
            share(dict)
        } else if message.name == "saveRedDot" {

        } else if message.name == "getRedDot" {

        } else if message.name == "getAgeBirth" {

        }
    }
    
    /// 检查订单
    func checkOrder(){
        NGNet.apiCheckOrder { flag, response, msg, dict in
            if flag {
                Totas.show("购买成功", .success) {
                    NGSDK.shared.sdkPayResult(true)
                }
            } else {
                let text = msg.isEmpty ? "购买失败" : msg
                Totas.show(text, .fail) {
                    NGSDK.shared.sdkPayResult(false)
                }
            }
        }
    }
}
