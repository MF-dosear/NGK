//
//  NGTestVC.swift
//  NGK
//
//  Created by Paul on 2023/3/2.
//

import UIKit
import WebKit

class NGTestVC: UIViewController, WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
    
    let funcs = [
        "closeWeb",
        "openSafari",
        "passValue",
        "copyGame",
        "toShareU",
        "saveRedDot",
        "getRedDot",
        "getAgeBirth"
    ]
    
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        webView = WKWebView(frame: view.bounds, configuration: config)
//        webView.uiDelegate = self
//        webView.navigationDelegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false

        webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(webView)
        
        let request = URLRequest(url: URL(string: "http://iosserver.ayouhuyu.com/sdk_turn_url.php?iosType=2&type=shareIOS&username=vm1677148962&sid=GjTq_2023_0302_1718_2216&sign=3a42152742e0d5d87a906869e247e4ed&appid=1000001&isnewcenter=2&hasNewSMRZ=1")!)
        webView.load(request)
    }
    
    deinit {
        if #available(iOS 14.0, *) {
            self.webView.configuration.userContentController.removeAllScriptMessageHandlers()
        } else {
            for func_name in self.funcs {
                self.webView.configuration.userContentController.removeScriptMessageHandler(forName: func_name)
            }
        }
    }
}
