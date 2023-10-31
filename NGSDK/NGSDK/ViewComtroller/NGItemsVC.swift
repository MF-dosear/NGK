//
//  NGItemsVC.swift
//  NGSDK
//
//  Created by Paul on 2023/2/28.
//

import UIKit

class NGItemsVC: NGSDKViewController {
    
    var frame: CGRect = CGRectZero
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let num = NGNet.shared.user.isShare == 1 ? 3 : 2
        let list = ["icon_账户","icon_分享","icon_注销"]
        
        let sp: CGFloat = 5
        let w: CGFloat = 45
        
        let count = num - 1
        for i in 0...count {
            
            let tag = (num == 2 && i == 1) ? 2 : i
            let btn = UIButton(type: .custom)
            btn.setBackgroundImage(UIImage.image(list[tag]), for: .normal)
            btn.addTarget(self, action: #selector(btnAction(_:)), for: .touchUpInside)
            btn.tag = tag + 1000
            
            let origin = frame.origin
            let size = frame.size
            let center_x = origin.x + size.width / 2
            
            if center_x < view.frame.size.width / 2 {
                
                let x:CGFloat = origin.x + size.width +  w * CGFloat(i) + sp * CGFloat(i + 1)
                let y:CGFloat = origin.y + size.height / 2 - w / 2
                btn.frame = CGRectMake(x, y, w, w)
            } else {
                
                let index = count - i
                let x:CGFloat = origin.x - size.width - w * CGFloat(index) - sp * CGFloat(index + 1)
                let y:CGFloat = origin.y + size.height / 2 - w / 2
                btn.frame = CGRectMake(x, y, w, w)
            }
            
            view.addSubview(btn)
        }
        
        
    }
    
    @objc func btnAction(_ btn: UIButton){
        
        dismiss(animated: true) {
            
            switch btn.tag {
                case 1000: self.accountAction()
                    break
                case 1001: self.shareAction()
                    break
                case 1002: self.logoutAction()
                    break
            default:
                break
            }
        }
    }
    
    /// 账号信息
    func accountAction(){
        let url = checkUrl(text: "newuser")
        let vc = NGApiVC(url: url, mode: .account)
        NGTool.currentvc().present(vc, animated: true)
    }
    
    /// 分享
    func shareAction(){
        let url = checkUrl(text: "shareIOS")
        let vc = NGApiVC(url: url, mode: .share)
        NGTool.currentvc().present(vc, animated: true)
    }
    
    /// 注销
    func logoutAction(){
        let vc = NGLogoutVC()
        NGNavigationController(rootViewController: vc).presentByCurrentvc()
    }
    
    /// 获取链接
    func checkUrl(text: String) -> String{
        
        let user = NGNet.shared.user
        let user_name = user.user_name ?? ""
        let sid       = user.sid ?? ""
        
        let dict:[String: Any] = [
            "username" : user_name,
            "sid"      : sid
        ]
        let sign = NGNet.shared.sign(text, "2fb959ad17fc7eec6a710680583baef6", dict)
        let url = "http://iosserver.ayouhuyu.com/sdk_turn_url.php?iosType=2&type=\(text)&username=\(user_name)&sid=\(sid)&sign=\(sign)&appid=\(NGNet.shared.app_id)&isnewcenter=2&hasNewSMRZ=1"
        return url
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        dismiss(animated: true)
    }
}
