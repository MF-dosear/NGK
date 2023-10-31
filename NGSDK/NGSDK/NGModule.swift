//
//  NGModule.swift
//  NGSDK
//
//  Created by Paul on 2023/2/27.
//

import Foundation
import SafariServices

extension NGSDK {
    
    /// APP内部Safari打开网页，可跳转App Store
    /// - Parameter url: 链接
    @objc public class func sdkOpenUrl(url: String?) {
        guard let api = URL(string: url ?? "") else {
            print("链接错误 无法发开")
            return
        }
        let vc = SFSafariViewController(url: api)
        NGTool.currentvc().present(vc, animated: true)
    }
    
    /// 绑定手机
    @objc public class func sdkBindPhone() {
        // 检测是否需要绑定手机号
        let mobile = NGNet.shared.user.mobile ?? ""
        if mobile.isEmpty {
            let vc = NGBindVC()
            vc.isDismiss = true
            NGNavigationController(rootViewController: vc).presentByCurrentvc()
        } else {
            // 不需要绑定，检测实名认证
            Totas.show("手机号已绑定")
        }
    }

    /// 供研发调用事件埋点
    /// - Parameters:
    ///   - event_name: 事件名
    ///   - jsonStr: 备注参数
    @objc public class func wdEventToEs(event_name: String, jsonStr: String){
        NGEvent.upload(event_name, play_session: "", properties: jsonStr)
    }
    
    /// 请求链接 
    /// - Parameter apple_id: 苹果AppID
    @objc public class func sdkApi(apple_id: String, result: @escaping (_ flag: Bool, _ url: String?) -> Void){
        NGNet.apiGame(apple_id) { flag, data, msg, dict in
            
            result(flag, data as? String ?? "")
        }
    }
    
    @objc func debugAction(){
        Totas.show("当前为debug模式，请切换至release模式")
    }
    
    #if DEBUG
    /// 网页UI测试 不需要对接改接口
    @objc public class func sdkShowTestVC() {
        
        let vc = NGTestVC()
        NGTool.currentvc().present(vc, animated: true)
    }
    
    #else
    #endif
}
