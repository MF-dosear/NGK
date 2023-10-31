//
//  File.swift
//  NGK
//
//  Created by Paul on 2023/2/13.
//

import UIKit
import NGSDK

class NGSwiftVC : UITableViewController{
    
    let list = [
        "登录",
        "上传角色",
        "支付",
        "登出",
        "系统分享",
        "QQ分享图片(优先级高)",
        "微信分享图片(优先级高)",
        "QQ分享链接(优先级中)",
        "微信分享链接(优先级中)",
        "QQ分享文本(优先级低)",
        "微信分享文本(优先级低)",
        "Safari打开网页",
        "绑定手机号",
        "测试页面"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Swift游戏SDK"
        
        NGSDK.sdkInit(app_id: "1000000", app_key: "48f2bd0d7ab066687f0ab2b85241ae34", link: "cwdzz", appld_id: "1670290308", jy_app_key: "", result: { flag in
            
        })
        
        NGSDK.sdkLogoutBack { flag in
            print("退出登录")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") ?? UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        cell.textLabel?.text = list[indexPath.item]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let image = UIImage(named: "image")
        let previewImage = UIImage(named: "previewImage")
        let url = "https://www.baidu.com"
        
        let role = Role()
        role.roleID     = "角色ID"
        role.roleName   = "角色名称"
        role.roleLevel  = "角色等级"
        role.serverId   = "服务器ID"
        role.serverName = "服务器名称"
        role.payLevel   = "支付等级"
        
        let order = Order()
        order.cpOrder   = String(format: "%.0f", Date().timeIntervalSince1970) // cp订单号
        order.cost      = "1" // 价格
        order.goodsID   = "商品ID"
        order.goodsName = "商品名称"
        order.extends   = "透传参数"
        order.notifyURL = "回调地址（可传参数"
        
        switch indexPath.row {
        case 0: NGSDK.sdkLogin(automatic: true) { flag, uid, sid, user_name in
            print("登录 flag = \(flag), uid = \(uid ?? ""), sid = \(sid ?? ""), user_name = \(user_name ?? "")")
        }
            break
        case 1: NGSDK.sdkSubmitRole(role: role) { flag in
            print("上传角色 flag = \(flag)")
        }
            break
        case 2: NGSDK.sdkPay(role: role, order: order) { flag in
            print("支付 flag = \(flag)")
        }
            break
        case 3: NGSDK.sdkLogout()
            break
        case 4: NGSDK.sdkShare(mode: .system, title: "标题", text: "内容", url: url, image: image, previewImage: nil)
            break
        case 5: NGSDK.sdkShare(mode: .QQ, title: "标题", text: "内容", url: nil, image: image, previewImage: previewImage)
            break
        case 6: NGSDK.sdkShare(mode: .wechat, title: "标题", text: "内容", url: nil, image: image, previewImage: previewImage)
            break
        case 7: NGSDK.sdkShare(mode: .QQ, title: "标题", text: "内容", url: url, image: nil, previewImage: nil)
            break
        case 8: NGSDK.sdkShare(mode: .wechat, title: "标题", text: "内容", url: url, image: nil, previewImage: previewImage)
            break
        case 9: NGSDK.sdkShare(mode: .QQ, title: "标题", text: "内容", url: nil, image: nil, previewImage: nil)
            break
        case 10: NGSDK.sdkShare(mode: .wechat, title: "标题", text: "内容", url: nil, image: nil, previewImage: nil)
            break
        case 11: NGSDK.sdkOpenUrl(url: "https://www.baidu.com")
            break
        case 12: NGSDK.sdkBindPhone()
            break
//        case 13: NGSDK.sdkShowTestVC()//present(NGTestVC(), animated: true)
//            break
        default: break
            
        }
    }
    
}



    
