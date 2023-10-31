//
//  NGSDK.swift
//  NGSDK
//
//  Created by Paul on 2023/2/13.
//

import Foundation
import UIKit
import AppTrackingTransparency
import AdSupport
import OneLoginSDK

@objc public class NGSDK: NSObject {
    
    typealias NGSDKResult = (_ flag: Bool) -> Void
    
    static let shared = NGSDK()
    
    private var tipView: NGTipView?
    
    var sdkInitResult   : NGSDKResult!
    var sdkLoginResult  : NGSDKResult!
    var sdkPayResult    : NGSDKResult!
    var sdkLogoutResult : NGSDKResult!
    
    /// SDK 初始化
    /// - Parameters:
    ///   - app_id: app_id
    ///   - app_key: app_key
    ///   - link: link 通用链接后缀
    ///   - appld_id: 苹果后台APP ID
    ///   - jy_app_key: 极验一键登录app_key
    ///   - result: 结果  结果 flag 成功：true 失败：false
    @objc public class func sdkInit(app_id: String, app_key: String, link: String, appld_id: String, jy_app_key: String, result: @escaping (_ flag: Bool) -> Void) {
        
        if NGNet.shared.is_init {
            print("请勿重复初始化")
            return
        }
        
        /// 初始化结果
        NGSDK.shared.sdkInitResult = { flag in
            
            
            if flag {
                // 初始化成功
                NGNet.shared.is_init = true
                
                // 分享初始化
                NGSDK.shared.sdkShareInit()
                
                // 心跳
                Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { timer in
                    NGEvent.headEvent()
                }
            }
            
            result(flag)
        }
        
        /// 添加通知
        NGSDK.shared.addNotification()
        
        /// 设置风格
        Totas.style(style: .dark)
        
        #if DEBUG
        
        /// 测试模式警告⚠️
        let debug = UIButton(type: .custom)
        debug.setBackgroundImage(UIImage.image("debug"), for: .normal)
        debug.imageView?.contentMode = .scaleAspectFit
        debug.backgroundColor = .orange
        UIApplication.shared.delegate?.window??.addSubview(debug)

        debug.snp.makeConstraints { make in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(88)
        }
        
        debug.addTarget(NGSDK.shared, action: #selector(debugAction), for: .touchUpInside)
        
        #else

        #endif
        
        /// 赋值
        NGNet.shared.app_id      = app_id
        NGNet.shared.app_key     = app_key
        NGNet.shared.link_suffix = link
        NGNet.shared.appld_id    = appld_id
        
        /// 极验初始化
        NGSDK.shared.initJYSDK(jy_app_key)
        
        /// 设置心跳值
        let timeInterval = Date().timeIntervalSince1970
        let play_session = String(format: "%.0f", timeInterval)
        UserDefaults.standard.set(play_session, forKey: "play_session_cache")
        UserDefaults.standard.synchronize()
        
        /// 获取idfa权限
        if #available(iOS 14, *) {
            
            ATTrackingManager.requestTrackingAuthorization { status in
                var idfa = ""
                if status == .authorized {
                    idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                } else {
                    idfa = "V:" + UIDevice.uuid()
                }
                
                DispatchQueue.main.async {
                    
                    NGSDK.shared.sdkCheckVersion(idfa)
                }
            }
            
        } else {
            var idfa = ""
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            } else {
                idfa = "V:" + UIDevice.uuid()
            }
            NGSDK.shared.sdkCheckVersion(idfa)
        }
    }
    
    /// 登录
    /// - Parameters:
    ///   - automatic: 是否自动登录
    ///   - result: 结果 flag 成功：true 失败：false 登录返回参数：uid、 sid、 user_name
    @objc public class func sdkLogin(automatic:Bool, result: @escaping (_ flag: Bool, _ uid: String?, _ sid: String?, _ user_name: String?) -> Void) {
        
        if NGNet.shared.is_init == false {
            print("请先完成初始化操作")
            return
        }
        
        if NGNet.shared.is_login {
            let user = NGNet.shared.user
            result(true, user.uid, user.sid, user.user_name)
            return
        }
        
        /// 登录结果
        NGSDK.shared.sdkLoginResult = { flag in
            
            NGNet.shared.is_login = flag
            
            let user = NGNet.shared.user
            if flag {
                // 登录成功
                // 展示悬浮框
                if NGNet.shared.user.buoyState == "open" {
                    NGSDK.shared.tipView = NGTipView()
                    NGSDK.shared.tipView?.show()
                }
                
                // 登录成功统计
                NGEvent.upload(.login_success)
                
                // 存储登录用户

                // 删除
                var member = Member.seleted(user.user_name ?? "")
                member?.delete()
                
                // 添加新的
                member = Member()
                member?.username = user.user_name
                member?.password = user.password
                member?.insert()
                
                UserDefaults.standard.set(user.mobile, forKey: "phone_login_cache") // 登录时手机号
                UserDefaults.standard.set(true, forKey: "auto_cache") // 自动登录
                UserDefaults.standard.synchronize()
            }
            
            result(flag, user.uid, user.sid, user.user_name)
        }
        
        let auto_cache = UserDefaults.standard.bool(forKey: "auto_cache")
        if automatic && auto_cache {
            // 自动登录
            let member = Member.first()
            let username = member?.username ?? ""
            let password = member?.password ?? ""
            
            NGNet.apiLogin(username, password) {flag, response, msg ,dict in
                if flag {
                    let data = response as? [String: Any]
                    NGNet.shared.user.trueNameSwitch = data?["trueNameSwitch"] as? String
                    
                    NGNet.shared.user.wx_appid = data?["wx_appid"] as? String
                    NGNet.shared.user.birthday = data?["birthday"] as? String
                    NGNet.shared.user.is_smrz  = data?["is_smrz"] as? Int
                    
                    NGNet.shared.user.profile = data?["profile"] as? String
                    NGNet.shared.user.qqappid = data?["qqappid"] as? String
                    NGNet.shared.user.userSex = data?["userSex"] as? Int
                    
                    NGNet.shared.user.trueName        = data?["trueName"] as? String
                    NGNet.shared.user.isBindMobile    = data?["isBindMobile"] as? Int
                    NGNet.shared.user.is_show_binding = data?["is_show_binding"] as? String
                    
                    NGNet.shared.user.drurl     = data?["drurl"] as? Int
                    NGNet.shared.user.isOldUser = data?["isOldUser"] as? Int
                    NGNet.shared.user.sid       = data?["sid"] as? String
                    
                    NGNet.shared.user.idCard    = data?["idCard"] as? String
                    NGNet.shared.user.buoyState = data?["buoyState"] as? String
                    NGNet.shared.user.uid       = data?["uid"] as? String
                    
                    NGNet.shared.user.mobile    = data?["mobile"] as? String
                    NGNet.shared.user.age       = data?["age"] as? String
                    NGNet.shared.user.nick_name = data?["nick_name"] as? String
                    
                    NGNet.shared.user.isShare   = data?["isShare"] as? Int
                    NGNet.shared.user.adult     = data?["adult"] as? Int
                    NGNet.shared.user.user_name = data?["user_name"] as? String
                    
                    NGNet.shared.user.password = password
                    
                    Totas.show("登录成功", .success) {
                        NGSDK.shared.checkBindPhone()
                    }
                    
                } else {
                    Totas.show(msg, .fail) {
                        NGSDK.shared.sdkLoginResult(false)
                        showLoginView()
                    }
                }
            }
        } else {
            // 登录框
            showLoginView()
        }
    }
        
    class private func showLoginView(){
        
        Totas.show()
        OneLoginPro.getPreGetTokenResult { result in
            Totas.dismiss()
            
            if OneLoginPro.isPreGetTokenResultValidate(){
            
                let vc = NGOneLoginVC()
                vc.phone = result?["number"] as? String
                NGNavigationController(rootViewController: vc).presentByCurrentvc()
            } else {
                let vc = NGPhoneLoginVC()
                vc.isRoot = true
                NGNavigationController(rootViewController: vc).presentByCurrentvc()
            }
        }
    }
    
    /// 角色上报 登录成功后调用
    /// - Parameters:
    ///   - role: 角色信息
    ///   - result: 结果 flag 成功：true 失败：false
    @objc public class func sdkSubmitRole(role: Role, result: @escaping (_ flag: Bool) -> Void) {
        
        NGNet.shared.role  = role

        var params = [String:Any]()
        params["roleID"]     = role.roleID
        params["roleName"]   = role.roleName
        params["roleLevel"]  = role.roleLevel
        
        params["serverId"]   = role.serverId
        params["serverName"] = role.serverName
        params["payLevel"]   = role.payLevel

        NGNet.apiSubmitRole(&params) { flag, data, msg, dict in
            result(flag)
        }
    }
    
    /// 支付
    /// - Parameters:
    ///   - role: 角色信息
    ///   - order: cp订单信息
    ///   - result: 结果 flag 成功：true 失败：false
    @objc public class func sdkPay(role: Role, order: Order, result: @escaping (_ flag: Bool) -> Void) {
        
        NGSDK.shared.sdkPayResult = { flag in
            
            
            result(flag)
        }
        
        NGNet.shared.role  = role
        NGNet.shared.order = order

        var params = [String:Any]()
        params["roleID"]     = role.roleID
        params["roleName"]   = role.roleName
        params["roleLevel"]  = role.roleLevel
        
        params["serverId"]   = role.serverId
        params["serverName"] = role.serverName
        params["payLevel"]   = role.payLevel

        params["cpOrder"]    = order.cpOrder
        params["cost"]       = order.cost
        params["goodsID"]    = order.goodsID

        params["goodsName"]  = order.goodsName
        params["extends"]    = order.extends
        params["notifyURL"]  = order.notifyURL
        
        NGNet.apiGetOrderID(&params) { flag, response, msg, dict in
            
            if flag {
                let data = response as? [String: Any]
                let url = data?["pay_url"] as? String ?? ""
                NGNet.shared.order.order_id = data?["order_id"] as? String
                
                let vc = NGApiVC(url: url, mode: .pay)
                NGNavigationController.init(rootViewController: vc, mode: .pay).presentByCurrentvc()
            } else {
                let text = msg.isEmpty ? "支付失败" : msg
                Totas.show(text, .fail) {
                    NGSDK.shared.sdkPayResult(false)
                }
            }
        }
    }
    
    /// 登出
    @objc public class func sdkLogout() {
        
        // 退出登录
        NGNet.shared.is_login = false
        NGNet.shared.user = NGUser()
        OneLoginPro.renewPreGetToken()
        UserDefaults.standard.set(false, forKey: "auto_cache") // 自动登录
        UserDefaults.standard.synchronize()
        
        // 悬浮框
        NGSDK.shared.tipView?.removeFromSuperview()
        NGSDK.shared.tipView = nil
         
        NGSDK.shared.sdkLogoutResult(true)
    }
    
    /// 登出回调
    @objc public class func sdkLogoutBack(result: @escaping (_ flag: Bool) -> Void) {
        
        NGSDK.shared.sdkLogoutResult = { flag in
            
            result(flag)
        }
    }
}

// didFinish
extension NGSDK {
    
    /// 添加通知
    func addNotification(){

        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminateNotification), name: UIApplication.willTerminateNotification, object: nil)
    }

    @objc func didBecomeActiveNotification(){
        print("didBecomeActiveNotification")
    }
    
    @objc func willTerminateNotification(){
        print("willTerminateNotification")
    }
    
    /// 第三方SDK初始化
    func initJYSDK(_ app_id: String){
        #if DEBUG
        let debug = true
        #else
        let debug = false
        #endif
        
        OneLoginPro.setLogEnabled(debug)
        OneLoginPro.register(withAppID: app_id)
    }
}

// sdkInit
extension NGSDK {
    
    /// 检查更新
    /// - Parameter idfa: idfa
    private func sdkCheckVersion(_ idfa: String){
        
        /// 存在idfa
        NGNet.shared.idfa = idfa
        /// 检查版本号
        NGNet.apiCheckVerion { [weak self] flag, response, msg ,dict in
            if flag {
                let data = response as? [String: Any]
                let url = data?["url"] as? String ?? ""
                let title = data?["title"] as? String ?? ""
                let appVersion = UIDevice.appVersion() ?? ""
                
                let serverVersion = Int(title.replacingOccurrences(of: ".", with: "")) ?? 0
                let localVersion  = Int(appVersion.replacingOccurrences(of: ".", with: "")) ?? 0
                
                let isUpdate:Bool = serverVersion > localVersion
                
//                let isUpdate = true
//                let url = "https://www.baidu.com/"
                
                if isUpdate && url.isEmpty == false {
                    // 更新页面
                    let vc = NGUpdateVC.init(url: url)
                    let nvc = NGNavigationController(rootViewController: vc)
                    nvc.presentByCurrentvc()
                } else {
                    // 检查公告
                    self?.sdkCheckNotice()
                }
            } else {
                // 初始化失败
                self?.sdkInitResult(false)
            }
        }
    }
    
    /// 检查公告
    private func sdkCheckNotice(){
        NGNet.apiCheckNotice { [weak self] flag, response, msg ,dict in
            
            if flag {
                
                let data = response as? [String: Any]
                let url = data?["content"] as? String ?? ""
//                #if DEBUG
//                let url = "https://www.baidu.com/"
//                #else
//                let url = data?["content"] as? String ?? ""
//                #endif
                
                // 是否展示公告
                if url.hasPrefix("http"){
                    let date = Date()
                    let fmt = DateFormatter()
                    fmt.dateFormat = "yyyy-MM-dd"
                    let time = fmt.string(from: date)
                    
                    let dict:[String: Bool] = UserDefaults.standard.object(forKey: "NoticeCache") as? [String : Bool] ?? [:]
                    
                    let isHave = dict[time] ?? false
                    if isHave {
                        // 展示过 初始化
                        self?.sdkCheckInit()
                    } else {
                        // 去展示
                        let vc = NGNoticeVC(url: url)
                        let nvc = NGNavigationController(rootViewController: vc)
                        nvc.presentByCurrentvc()
                        
                        let values = [time : true]
                        UserDefaults.standard.set(values, forKey: "NoticeCache")
                        UserDefaults.standard.synchronize()
                    }
                    
                } else {
                    // 初始化
                    self?.sdkCheckInit()
                }
            } else {
                // 初始化失败
                self?.sdkInitResult(false)
            }
        }
    }
    
    /// 检查初始化
    func sdkCheckInit() {
        
        NGEvent.upload(.active_start) // 初始化开始上报
        NGNet.apiInit {[weak self] flag, response, msg ,dict in
            
            if (flag == false) {
                self?.sdkInitResult(true)
            } else {
                
                let data = response as? [String: Any]
                NGNet.shared.config.wx_appid = data?["wx_appid"] as? String
                NGNet.shared.config.ios_gameid = data?["ios_gameid"] as? Int
                NGNet.shared.config.is_open_yange = data?["is_open_yange"] as? String
                
                NGNet.shared.config.qqappid = data?["qqappid"] as? String
                NGNet.shared.config.gameName = data?["gameName"] as? String
                NGNet.shared.config.exit_image_click_url = data?["exit_image_click_url"] as? String
                
                NGNet.shared.config.is_open_smrz = data?["is_open_smrz"] as? String
                NGNet.shared.config.is_open_wxlogin = data?["is_open_wxlogin"] as? String
                NGNet.shared.config.bf_time = data?["bf_time"] as? Int
                
                NGNet.shared.config.is_jm_reglogin = data?["is_jm_reglogin"] as? String
                NGNet.shared.config.exit_image_url = data?["exit_image_url"] as? String
                NGNet.shared.config.questionid = data?["questionid"] as? Int
                
                NGNet.shared.config.user_private = data?["user_private"] as? String
                NGNet.shared.config.android_gameid = data?["android_gameid"] as? Int
                NGNet.shared.config.Universal_Link = data?["Universal_Link"] as? String
                
                NGNet.shared.config.isgdt = data?["isgdt"] as? String
                NGNet.shared.config.user_protocol = data?["user_protocol"] as? String
                NGNet.shared.config.is_user_protocol = data?["is_user_protocol"] as? String
                
                NGNet.shared.config.cp_fangchenmi = data?["cp_fangchenmi"] as? String
//                NGNet.shared.config.isShare = data?["isShare"] as? String
                NGNet.shared.config.smrz_show_close_button = data?["smrz_show_close_button"] as? String

                NGNet.shared.config.newsid = data?["newsid"] as? Int
                
                var dict:[String: Int] = [:]
                if NGNet.shared.config.newsid ?? 0 > 0 {
                    dict["newsid"] = NGNet.shared.config.newsid
                }
                
                if NGNet.shared.config.questionid ?? 0 > 0{
                    dict["questionid"] = NGNet.shared.config.questionid
                }
                
                if NGNet.shared.config.ios_gameid ?? 0 > 0 {
                    dict["ios_gameid"] = NGNet.shared.config.ios_gameid
                }
                
                NGNet.shared.config.RedDotDic = dict
                
                self?.sdkInitResult(true)
                
                NGEvent.upload(.active_success) // 初始化成功上报
            }
        }
    }
    
    /// 检测绑定手机号
    func checkBindPhone(){
        
        let user = NGNet.shared.user
        if user.is_show_binding == "1" {
            if (user.mobile?.count ?? 0 > 0) {
                // 不需要绑定，检测实名认证
                checkAuth()
            } else {
                // 是否今日不再提醒
                let date = Date()
                let fmt = DateFormatter()
                fmt.dateFormat = "yyyy-MM-dd"
                let time = fmt.string(from: date)
                
                let key = "bind_phone_cache_" + (user.user_name ?? "")
                let dict:[String: Bool] = UserDefaults.standard.object(forKey: key) as? [String : Bool] ?? [:]
                
                let isHave = dict[time] ?? false
                if isHave {
                    // 不需要绑定，检测实名认证
                    checkAuth()
                } else {
                    // 前去 绑定
                    let nvc = NGNavigationController(rootViewController: NGBindVC())
                    nvc.presentByCurrentvc()
                    
                    UserDefaults.standard.set([time:true], forKey: key)
                    UserDefaults.standard.synchronize()
                }
            }
        } else {
            // 检测实名认证
            checkAuth()
        }
    }
    
    /// 实名认证
    func checkAuth(){
        
        let is_open_smrz = NGNet.shared.config.is_open_smrz ?? "0"
        let is_smrz = NGNet.shared.user.is_smrz ?? 0
        
        if (is_open_smrz != "1" || is_smrz  == 1) {
            // 没有开启实名认证 或者 实名认证成功
            NGSDK.shared.sdkLoginResult(true)
        } else {
            // 实名认证
            let nvc = NGNavigationController(rootViewController: NGAuth(), mode: .pay)
            nvc.presentByCurrentvc()
        }
    }
    
}
