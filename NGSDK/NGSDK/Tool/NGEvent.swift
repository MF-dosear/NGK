//
//  NGEvent.swift
//  NGSDK
//
//  Created by Paul on 2023/2/17.
//

import Foundation

enum NGEventMode: String {
    case active_start       = "sdk_active_start"        //   (SDK的初始化接口请求开始)
    case active_success     = "sdk_active_success"      //   (SDK的初始化接口请求成功)
    case register_success   = "sdk_register_success"    //   (SDK的注册成功)
    
    case login_success      = "sdk_login_success"       //   (SDK登录成功)
    case accountlogin_show  = "sdk_accountlogin_show"   //   (SDK账号密码登录界面展示)
    case phonereg_show      = "sdk_phonereg_show"       //   (SDK手机号密码注册界面展示)
    
    case phonelogin_show    = "sdk_phonelogin_show"     //   (SDK手机号验证码登录界面展示)
    case quickreg_show      = "sdk_quickreg_show"       //   (SDK快速注册界面展示)
    case geelogin_show      = "sdk_geelogin_show"       //   (SDK极验登录界面展示)
    
    case realname_show      = "sdk_realname_show"       //   (SDK实名界面展示)
    case realname_commit    = "sdk_realname_commit"     //   (SDK点击提交实名认证)
    case realname_success   = "sdk_realname_success"    //   (SDK实名成功)
}

class NGEvent{
    
    /// 上报事件
    /// - Parameter event: 事件名称
    class func upload(_ event: NGEventMode){
        NGNet.apiUploadEvent(event: event.rawValue, play_session: "", properties: "")
    }
    
    class func upload(_ event: String, play_session: String, properties: String){
        NGNet.apiUploadEvent(event: event, play_session: play_session, properties: properties)
    }
    
    /// 心跳
    class func headEvent(){
        
        let play_session = UserDefaults.standard.object(forKey: "play_session_cache") as? String ?? ""
        
        let role = NGNet.shared.role
        var params = [String: Any]()
        params["roleID"]   = role.roleID
        params["roleName"] = role.roleName
        params["roleLV"]   = role.roleLevel
        
        params["serverID"]   = role.serverId
        params["serverName"] = role.serverName
        params["payLevel"]   = role.payLevel
        
        let properties = params.jsonString() ?? ""
        NGNet.apiUploadEvent(event: "play_session", play_session: play_session, properties: properties)
    }
}
