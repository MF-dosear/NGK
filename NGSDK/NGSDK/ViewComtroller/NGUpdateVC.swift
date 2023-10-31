//
//  NGUpdateVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/16.
//

import UIKit

class NGUpdateVC: NGViewController {
    
    private var url:String!
    
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgView.image = UIImage.image("版本更新")
        
        backBtn.removeFromSuperview()
        
        let button = NGButton.button("立即更新")
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.equalTo(button_horizontal)
            make.right.equalTo(-button_horizontal)
            make.height.equalTo(button_height)
            make.bottom.equalTo(-35)
        }
        
        let up_imgView = UIImageView()
        up_imgView.contentMode = .scaleAspectFit
        up_imgView.image = UIImage.image("icon_升级")
        view.addSubview(up_imgView)
                
        up_imgView.snp.makeConstraints { make in
            make.top.equalTo(imgView.snp.bottom).offset(30);
            make.left.right.equalTo(0);
            make.bottom.equalTo(button.snp.top).offset(-10);
        }
        
        button.addTarget(self, action: #selector(btnAction), for: .touchUpInside)
    }
    
    @objc private func btnAction(){
        
        url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? url
        guard let url = URL(string: url) else {
            return print("更新链接错误")
        }
        UIApplication.shared.open(url)
    }
}
