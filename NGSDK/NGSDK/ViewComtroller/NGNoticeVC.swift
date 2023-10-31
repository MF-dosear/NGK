//
//  NGNoticeVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/17.
//

import UIKit
import WebKit

class NGNoticeVC: NGViewController {
    
    private var url:String!
    private let webView = WKWebView.init()
    
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("公告栏")
        setCloseBtn()

        view.addSubview(webView)
        
        let lf = 10
        let top = 16
        let bottom = 10
        webView.snp.makeConstraints { make in
            make.left.equalTo(lf)
            make.right.equalTo(-lf)
            make.top.equalTo(imgView.snp.bottom).offset(top)
            make.bottom.equalTo(-bottom)
        }
        
        guard let url = URL(string: self.url) else { return print("公告链接错误") }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func backBtnAction() {
        
        dismiss(animated: true, completion: {
            NGSDK.shared.sdkCheckInit()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.layer.cornerRadius = 5
    }
}
