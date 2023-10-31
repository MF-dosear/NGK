//
//  NGConfig.swift
//  NGSDK
//
//  Created by Paul on 2023/2/17.
//

import Foundation

class NGConfig {
    
    //************初始化信息************//
    var wx_appid: String? // 微信appid
    var ios_gameid: Int?
    var is_open_yange: String? // 严格实名认证
    
    var qqappid: String?
    var gameName: String?
    var exit_image_click_url: String?
    
    var is_open_smrz: String? // 是否开启实名认证
    var is_open_wxlogin: String? // 是否开启微信登录
    var bf_time: Int? // bf_time
    
    var is_jm_reglogin: String?
    var exit_image_url: String?
    var questionid: Int?
    
    var user_private: String? // 隐私条款
    var android_gameid: Int?
    var Universal_Link: String?
    
    var isgdt: String? // 广点通
    var user_protocol: String?
    var is_user_protocol: String? // 是否开启协议
    
    var cp_fangchenmi: String? // 防沉迷
//    var isShare: String?
    var smrz_show_close_button: String? // 是否开启实名认证的开关
    
    var newsid: Int?
    
    // 其他信息
    var RedDotDic: [String: Int]? // 红点

}

class NGUser {
    //************用户登录信息************//
    
    var trueNameSwitch: String? //
    
    var wx_appid: String? // 微信appid
    var birthday: String? // 生日
    var is_smrz: Int?     // 是否实名认证成功
    
    var profile: String?
    var qqappid: String?
    var userSex: Int?
    
    var trueName: String?
    var isBindMobile: Int? // 是否绑定
    var is_show_binding: String? // 是否展示绑定
    
    var drurl: Int?
    var isOldUser: Int?
    var sid: String?
    
    var idCard: String?
    var buoyState: String?
    var uid: String?
    
    var mobile: String?
    var age: String?
    var nick_name: String?
    
    var isShare: Int?
    var adult: Int?
    var user_name: String?
    
    // 其他信息
    var password: String?
}
