//
//  NGTestVC.swift
//  NGSDK
//
//  Created by Paul on 2023/3/3.
//

import UIKit

class NGTestVC : UITableViewController{
    
    let list = [
        "一键登录",
        "账号登录",
        "手机号登录",
        "快速注册",
        "手机号注册",
        "绑定手机号",
        "找回密码",
        "重置密码",
        "实名认证",
        "强制更新",
        "公告",
        "注销",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        var vc:NGSDKViewController!
        switch indexPath.row {
            case 0: vc = NGOneLoginVC()
                break
            case 1: vc = NGAccountVC()
                break
            case 2: vc = NGPhoneLoginVC()
                break
            case 3: vc = NGFastRegVC()
                break
            case 4: vc = NGPhoneRegVC()
                break
            case 5: vc = NGBindVC()
                break
            case 6: vc = NGFindVC()
                break
            case 7: vc = NGResetVC()
                break
            case 8: vc = NGAuth()
                break
            case 9: vc = NGUpdateVC(url: "https://www.baidu.com")
                break
            case 10: vc = NGNoticeVC(url: "https://www.baidu.com")
                break
            case 11: vc = NGLogoutVC()
                break
            default:
                break
        }
        
        NGNavigationController(rootViewController: vc, mode: .pay).presentByCurrentvc()
    }
}

