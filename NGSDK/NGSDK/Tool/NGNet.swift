//
//  NGNet.swift
//  NGSDK
//
//  Created by Paul on 2023/2/15.
//

import WebKit

enum NGNetMethod: String {
    case get  = "GET"
    case post = "POST"
}

enum NGApi: String {
    
    case sdkApi                 = "http://iosserver.ayouhuyu.com/index.php" // 域名
    case sdkWapApi              = "http://wapserver.ayouhuyu.com" // wap 域名
    case sdkEventApi            = "http://receiver.xmwan.com" // 事件上报api

    case initsdk                = "sdk.game.initsdk"                // 初始化
    case versionUpdate          = "sdk.info.versionUpdate"          // 检查版本
    case announcement           = "sdk.info.announcement"           // 公告
    
    case reg                    = "sdk.user.reg"                    // 注册
    case mobileReg              = "sdk.user.mobileReg"              // 手机注册
    case code                   = "sdk.user.code"                   // 获取验证码
    
    case checkUserMobileCode    = "sdk.user.checkUserMobileCode"    // 验证验证码
    case updateByPhonePwd       = "sdk.user.updateByPhonePwd"       // 忘记密码
    case bindMobile             = "sdk.user.bindMobile"             // 绑定手机
    
    case login                  = "sdk.user.login"                  // 登录
    case wxLogin                = "sdk.user.wxLogin"                // 微信登录
    case shimingvalidate        = "sdk.game.shimingvalidate"        // 实名认证
    
    case entergame              = "sdk.game.entergame"              // 上传角色信息
    case getPayState            = "sdk.pay.getPayState"             // 获取状态
    case fororder               = "sdk.pay.fororder"                // 获取订单号
    
    case apple2                 = "sdk.pay.apple2"                  // 苹果支付
    case query2                 = "sdk.pay.query2"                  // 验证订单
    case ioslogin               = "ioslogin"                        // 一键登录
    
    case aliAutoUpdatePwd       = "sdk.user.aliAutoUpdatePwd"       // 重置密码
    case codelogin              = "sdk.user.codelogin"              // 手机登录
    
    
}

typealias NGResult = (_ flag: Bool, _ response: Any?, _ msg: String, _ dict: [String : AnyObject]?) -> (Void)

class NGNet {
    
    static let shared = NGNet()

    private var userAgent: String = ""
    
    static private let AES128_KEY = "UEUJJWQQKLAOILQN"
    static private let AES128_VI = "618336901"
    
    let config = NGConfig()
    var user   = NGUser()
    var role   = Role()
    var order  = Order()
    
    var is_init = false // 是否初始化成功
    var is_login = false // 是否登录成功
    
    var is_qq     = false // QQ分享
    var is_wechat = false // 微信分享
    
    /// sdk 订单信息
   //    var psy_state: Int?
   //    var orderID: String?
   //    var goodbye: String?
    
    var app_id           = ""
    var app_key          = ""
    var link_suffix      = ""
    var appld_id         = ""
    var idfa             = ""
    
    private func request(_ method: NGNetMethod, _ api: NGApi, _ params: [String: Any]?, reslut: NGResult? = nil, isShowLoading: Bool = true){
        
        if self.userAgent.isEmpty {
            
            WKWebView().evaluateJavaScript("navigator.userAgent") { data, error in
                
                if data != nil && data is String{
                    self.userAgent = data as? String ?? ""
                    self.http(method, api, params, reslut: reslut, isShowLoading: isShowLoading)
                } else {
                    self.http(method, api, params, reslut: reslut, isShowLoading: isShowLoading)
                }
            }
        } else {
            self.http(method, api, params, reslut: reslut, isShowLoading: isShowLoading)
        }
    }
    
    private func http(_ method: NGNetMethod, _ api: NGApi, _ params: [String: Any]?, reslut: NGResult? = nil, isShowLoading: Bool = true){
        
        var data_dict:[String: Any] = params ?? [:]
        data_dict["channel"] = "AppStore"
        data_dict["udid"] = idfa
        data_dict["idfa"] = idfa

        data_dict["ssid"] = "ssid"
        data_dict["ptmodel"] = UIDevice.platform()

        let data_json = data_dict.jsonString()?.replacingOccurrences(of: "\n", with: "")

        var info:[String: Any] = [:]
        info["appid"] = app_id
        info["service"] = api.rawValue
        info["data"] = data_json

        info["platform"] = "iOS"
        info["sign"] = sign(api.rawValue, app_key, data_dict)

//        print(info)

        guard let url = URL(string: NGApi.sdkApi.rawValue) else { return print("接口创建失败") }

        var timeout:TimeInterval = 30
        if api == .initsdk{
            // 初始化时间
            timeout = 10
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeout)
        request.httpMethod = method.rawValue
        let httpBody = body(info)
        request.httpBody = httpBody.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["userAgent" : userAgent]

        let session = URLSession(configuration: config)

        if isShowLoading {Totas.show()} // 加载圈显示
        let task = session.dataTask(with: request) {[weak self] data, response, error in

            DispatchQueue.main.async {

                if isShowLoading {Totas.dismiss()} // 加载圈消失
                if error == nil {
                    self?.format(api, data, reslut: reslut)
                } else {
                    reslut?(false,nil,"请求失败", nil)
                }
            }
        }

        task.resume()
    }
    
    private class func get(_ api: NGApi, _ params: [String: Any]?, reslut: NGResult? = nil, isShowLoading: Bool = true){
        NGNet.shared.request(.get, api, params, reslut: reslut, isShowLoading: isShowLoading)
    }
    
    private class func post(_ api: NGApi, _ params: [String: Any]?, reslut: NGResult? = nil, isShowLoading: Bool = true){
        NGNet.shared.request(.post, api, params, reslut: reslut, isShowLoading: isShowLoading)
    }

}

extension NGNet {
    /// 生成sign
    func sign(_ url: String, _ app_key: String, _ info: [String : Any]) -> String{
        
        var str = app_id + url
        let result = info.keys.sorted()
        
        var split = ""
        for key in result{
            let value = info[key] ?? ""
            str = "\(str)\(split)\(key)=\(value)"
            split = "&"
        }
        
        str = str + app_key
        var text = str.encode_url()
        text = text.md5()
        return text
    }
    
    func body(_ params: [String : Any]) -> String{
        
        var jsonStr = ""
        if params.isEmpty {
            return ""
        }
        
        let keys = params.keys
        for key in keys {
            let value = params[key] as? String ?? ""
            jsonStr = "\(jsonStr)\(key.encode())=\(value.encode())&"
        }
        
        jsonStr = "\(jsonStr.prefix(jsonStr.count - 1))"
        return jsonStr
    }
    
    func format(_ api: NGApi, _ data: Data?, reslut: NGResult? = nil){
        
        guard let jsonData = data else {
            
            reslut?(false, nil, "data没有数据", nil)
            return
        }
        
        guard let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String : AnyObject] else {
            reslut?(false, nil, "数据解析失败", nil)
            return
        }
        
//        print(dict)
        
        guard let sta = dict["state"] as? [String : AnyObject] else {
            reslut?(false, nil, "数据解析失败", nil)
            return
        }
        
        let code = sta["code"] as? Int ?? 0
        let msg = sta["msg"] as? String ?? ""
        let info = dict["data"]
        if code == 1 {
            reslut?(true, info, msg, dict)
        } else {
            reslut?(false, info, msg, dict)
        }
    }
    
    func decodeAES128Data(_ text: String) -> [String: Any]?{
        
        guard let text_base64_bytes = Data(base64Encoded: text, options: .ignoreUnknownCharacters)?.bytes else {
            
            print("text base64Encoded 失败")
            return nil
        }
    
        guard let encrypted = try? AES(key: NGNet.AES128_KEY.bytes, blockMode: ECB()).decrypt(text_base64_bytes) else {
        
            print("text AES128解密 失败")
            return nil
        }
        
        let data = Data(bytes: encrypted, count: encrypted.count)
        var text = String(data: data, encoding: .utf8)
        text = text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        text = text?.trimmingCharacters(in: CharacterSet.controlCharacters)
        
        guard let jso_data = text?.data(using: .utf8) else {
        
            print("text 转 Data 失败")
            return nil
        }
        
        guard let dict = try? JSONSerialization.jsonObject(with: jso_data, options: .fragmentsAllowed) as? [String: Any] else {
            print("jso_data 转 jso_data 失败")
            return nil
        }
        
        return dict
    }

}

extension NGNet{
    
    /// 检查版本号
    /// - Parameter reslut: 结果
    class func apiCheckVerion(reslut: NGResult? = nil){
        
        let version = UIDevice.appVersion()?.replacingOccurrences(of: ".", with: "") ?? ""
        NGNet.post(NGApi.versionUpdate, ["gameversion" : version], reslut: reslut, isShowLoading: false)
    }
    
    /// 检查公告
    /// - Parameter reslut: 结果
    class func apiCheckNotice(reslut: NGResult? = nil){
        NGNet.post(NGApi.announcement, nil, reslut: reslut, isShowLoading: false)
    }
    
    /// 初始化
    /// - Parameter reslut: 结果
    class func apiInit(reslut: NGResult? = nil){
        NGNet.post(NGApi.initsdk, nil, reslut: reslut, isShowLoading: false)
    }
    
    /// 账号密码登录
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    class func apiLogin(_ username: String, _ password: String, reslut: NGResult? = nil){
        var params = [String:Any]()
        params["username"] = username
        params["passwd"]   = password.md5()
        params["passwdMW"] = password
        NGNet.post(NGApi.login, params, reslut: reslut)
    }
    
    /// 手机号登录
    /// - Parameters:
    ///   - mobile: 手机号
    ///   - code: 验证码
    ///   - reslut: 结果
    class func apiPhoneLogin(_ phone: String, _ code: String, reslut: NGResult? = nil){
        var params = [String:Any]()
        params["mobile"] = phone
        params["code"]   = code
        NGNet.post(NGApi.codelogin, params, reslut: reslut)
    }
    
    /// 快速注册
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - reslut: 结果
    class func apiFastReg(_ username: String, _ password: String, reslut: NGResult? = nil){
        var params = [String:Any]()
        params["username"] = username
        params["passwd"]   = password.md5()
        params["passwdMW"] = password
        NGNet.post(NGApi.reg, params, reslut: reslut)
    }
    
    /// 手机号注册
    /// - Parameters:
    ///   - phone: 手机号
    ///   - code: 验证码
    ///   - password: 密码
    ///   - reslut: 结果
    class func apiPhoneReg(_ phone: String, _ code: String, _ password: String, reslut: NGResult? = nil){
        var params = [String:Any]()
        params["username"] = phone
        params["code"]     = code
        params["passwd"]   = password.md5()
        NGNet.post(NGApi.mobileReg, params, reslut: reslut)
    }
    
    /// 绑定手机号
    /// - Parameters:
    ///   - phone: 手机号
    ///   - code: 验证码
    ///   - reslut: 结果
    class func apiBindPhone(_ phone: String, _ code: String, reslut: NGResult? = nil){
        var params = [String:Any]()
        params["mobile"]   = phone
        params["code"]     = code
        params["username"] = NGNet.shared.user.user_name
        params["passwdMW"] = NGNet.shared.user.password
        NGNet.post(NGApi.bindMobile, params, reslut: reslut)
    }
    
    /// 实名认证
    /// - Parameters:
    ///   - name: 姓名
    ///   - idCard: 身份证
    ///   - reslut: 结果
    class func apiAuth(_ name: String, _ idCard: String, reslut: NGResult? = nil){
        var params = [String:Any]()
        params["name"]     = name
        params["idcard"]   = idCard
        params["username"] = NGNet.shared.user.user_name
        params["uid"]      = NGNet.shared.user.uid
        NGNet.post(NGApi.shimingvalidate, params, reslut: reslut)
    }
    
    /// 发送验证码
    /// - Parameters:
    ///   - phone: 手机号
    ///   - smsType: 0绑定1解绑2找回密码3注册4根据手机号码解绑手机5活动验证码6设置二级密码7重置二级密码
    ///   - reslut: 结果
    class func apiSendCode(_ phone: String, _ smsType: String, reslut: NGResult? = nil){
        var params = [String:Any]()
        params["mobile"]   = phone
        params["smsType"]  = smsType
        params["username"] = NGNet.shared.user.user_name
        NGNet.post(NGApi.code, params, reslut: reslut)
    }
    
    /// 更新密码
    /// - Parameters:
    ///   - phone: 手机号
    ///   - code: 验证码
    ///   - password: 密码
    ///   - reslut: 结果
    class func apiUpdatePassword(_ phone: String, _ code: String, _ password: String, reslut: NGResult? = nil){
        var params = [String:Any]()
        params["username"]   = phone
        params["mobile"]   = phone
        params["code"]   = code
        params["passwd"]  = password.md5()
        params["passwdMW"] = password
        NGNet.post(NGApi.updateByPhonePwd, params, reslut: reslut)
    }
    
    /// 重置密码
    /// - Parameters:
    ///   - username: 用户名
    ///   - token: token
    ///   - password: 密码
    ///   - reslut: 结果
    class func apiReset(_ username: String, _ token: String, _ password: String, reslut: NGResult? = nil){
        var params = [String:Any]()
        params["username"] = username
        params["passwd"]   = password
        params["token"]    = token
        NGNet.post(NGApi.aliAutoUpdatePwd, params, reslut: reslut)
    }
    
    /// 角色上传
    /// - Parameters:
    ///   - role: 角色 字典 参数 roleID roleName roleLevel serverId serverName payLevel
    ///   - reslut: 结果
    class func apiSubmitRole(_ params: inout [String: Any], reslut: NGResult? = nil){

        params["username"] = NGNet.shared.user.user_name
        params["uid"]      = NGNet.shared.user.uid
        NGNet.post(NGApi.entergame, params, reslut: reslut, isShowLoading: false)
    }
    
    /// 获取支付状态
    /// - Parameters:
    ///   - roleLevel: 角色等级
    ///   - reslut: 结果
    class func apiPsyState(_ roleLevel: String, reslut: NGResult? = nil){
        
        var params = [String:Any]()
        params["roleLevel"] = roleLevel
        params["username"]  = NGNet.shared.user.user_name
        params["mobile"]    = NGNet.shared.user.mobile
        NGNet.post(NGApi.getPayState, params, reslut: reslut)
    }
    
    /// 校验订单
    /// - Parameters:
    ///   - reslut: 结果
    class func apiCheckOrder(reslut: NGResult? = nil){
        
        var params = [String:Any]()
        params["order_id"] = NGNet.shared.order.order_id
        NGNet.post(NGApi.query2, params, reslut: reslut)
    }
    
    /// 获取订单号
    /// - Parameters:
    ///   - order: 订单信息 参数
    ///   roleID roleName roleLevel serverId serverName payLevel
    ///   cost goodsID goodsName extends notifyURL
    ///   - reslut: 结果
    class func apiGetOrderID(_ params: inout [String: Any], reslut: NGResult? = nil){
        
        params["username"] = NGNet.shared.user.user_name
        NGNet.post(NGApi.fororder, params, reslut: reslut)
    }
    
    /// 请求游戏链接
    /// - Parameters:
    ///   - apple_id: 苹果ID
    ///   - reslut: 结果
    class func apiGame(_ apple_id: String, reslut: NGResult? = nil){
        
        let version = UIDevice.appVersion() ?? ""
        var api = "\(NGApi.sdkWapApi.rawValue)/api/gameh5data.php?act=appinfocry&version=\(version)&appid=\(apple_id)"
        api = api.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? api
        
        guard let url = URL(string: api) else { return print("接口创建失败") }
        var request = URLRequest(url: url)
        request.httpMethod = NGNetMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) {data, response, error in
        
            DispatchQueue.main.async {
                
                guard let jsonData = data else {
                    
                    reslut?(false, nil, "data没有数据", nil)
                    return
                }
                
                guard let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed) as? [String : AnyObject] else {
                    reslut?(false, nil, "数据解析失败", nil)
                    return
                }
                
                guard let text = dict["data"] as? String else {
                    
                    reslut?(false, nil, "data没有数据", nil)
                    return
                }
                
                let aes_data = NGNet.shared.decodeAES128Data(text)
                let code = aes_data?["code"] as? Int ?? 404
                let msg = aes_data?["msg"] as? String ?? ""
                if code == 0 {
                    
                    let info = aes_data?["data"] as? [String: Any]
                    
                    let isShow = info?["isShow"] as? String ?? ""
                    let result_url = info?["url"] as? String ?? ""
                    
                    if isShow == "1" && result_url.isEmpty == false {
                        reslut?(true, result_url, msg, nil)
                    } else {
                        reslut?(false, nil, msg, nil)
                    }
                    
                } else {
                    reslut?(false, nil, msg, nil)
                }
            }
        }
        
        task.resume()
    }
    
    /// 上报事件
    /// - Parameters:
    ///   - event: 事件名
    ///   - properties: 参数
    class func apiUploadEvent(event: String, play_session: String, properties: String){
        
        var params = [String: Any]()
        params["#account_id"] = NGNet.shared.user.uid
        params["#appid"]      = NGNet.shared.app_id
        params["#event_name"] = event
        
        params["#ip"]   = ""
        params["#type"] = "track"
        
        if play_session.isEmpty == false {
            params["#play_session"] = play_session
        }
        
        if properties.isEmpty == false {
            let dict = properties.dictionaryValue()
            params["properties"] = dict
        }
        
        let date = Date()
        let timeInterval = date.timeIntervalSince1970
        let str = String(format: "%lf", timeInterval)
        params["#uuid"] = UUID.init(uuidString: str)
        
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        params["#time"] = fmt.string(from: date)
        
//        let system = UIDevice.current.systemVersion
        let device:[String: String?] = [
            "#device_id"    : NGNet.shared.idfa,
            "#idfa"         : NGNet.shared.idfa,
            
            "#device_model" : UIDevice.platform(),
            "#app_version"  : UIDevice.appVersion(),
            "#lib_version"  : "0.2.2",
            
            "#os_version" : UIDevice.systemVersion(),
            "#manufacturer" : UIDevice.platform(),
            "#os" : "iOS",
            "#bundle_id" : UIDevice.bundleID(),
        ]
        
        params["#device"] = device
        
        let url = URL(string: NGApi.sdkEventApi.rawValue)
        var request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30.0)
        request.httpMethod = NGNetMethod.post.rawValue
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if error == nil {
                print("事件上报成功")
            } else {
                print("事件上报失败")
            }
        }
        task.resume()
    }
    
    /// 一键登录
    /// - Parameters:
    ///   - process_id: process_id
    ///   - token: token
    ///   - authcode: authcode
    ///   - reslut: 结果
    class func apiOneLogin(process_id: String, token: String, authcode: String, reslut: NGResult? = nil){
        
        var params = [String: String]()
        
        params["act"] = NGApi.ioslogin.rawValue
        params["process_id"] = process_id
        params["token"] = token
        
        params["authcode"] = authcode
        params["from"] = "geetest"
        params["appid"] = NGNet.shared.app_id
        
        params["udid"] = NGNet.shared.idfa
        params["channel"] = "111111"
        params["ptmodel"] = UIDevice.platform()
        
        var api = NGApi.sdkWapApi.rawValue + "/api/onelogin.php?"
        for key in params.keys {
            let value = params[key] ?? ""
            api = String(format: "%@&%@=%@", api, key, value)
        }
        api = api.replacingOccurrences(of: "?&", with: "?")
        api = api.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? api
        
        guard let url = URL(string: api) else { return print("接口创建失败") }
        var request = URLRequest(url: url)
        request.httpMethod = NGNetMethod.get.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(NGNet.shared.userAgent, forHTTPHeaderField: "User-Agent")
        
        let session = URLSession.shared
        Totas.show()
        let task = session.dataTask(with: request) {data, response, error in
            DispatchQueue.main.async {
                Totas.dismiss()
                
                if error == nil {
                    NGNet.shared.format(NGApi.ioslogin, data, reslut: reslut)
                } else {
                    reslut?(false,nil,"请求失败", nil)
                }
            }
        }
        task.resume()
    }
}
