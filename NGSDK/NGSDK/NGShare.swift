//
//  NGShare.swift
//  NGSDK
//
//  Created by Paul on 2023/2/24.
//

import Foundation
import UIKit

extension NGSDK {
    
    /// QQ和微信分享初始化
    func sdkShareInit(){
        
        let config = NGNet.shared.config
        let wx_appid = config.wx_appid ?? ""
        if wx_appid.isEmpty == false {
            WXApi.startLog(by: .detail) { log in
                
                #if DEBUG
                print(log)
                #else
                
                #endif
            }
            let link_prefix = config.Universal_Link ?? ""
            let link_suffix = NGNet.shared.link_suffix
            let link = link_prefix + link_suffix
            NGNet.shared.is_wechat = WXApi.registerApp(wx_appid, universalLink: link)
        } else {
            #if DEBUG
            print("wx_appid缺失，微信SDK注册失败")
            #else
            
            #endif
        }
        
        let qqappid = config.qqappid ?? ""
        if qqappid.isEmpty == false {
            let link_prefix = config.Universal_Link ?? ""
            let link = link_prefix + "/qq_conn/" + qqappid
            let auth = TencentOAuth.init(appId: qqappid, andUniversalLink: link, andDelegate: nil)
            if auth != nil {
                NGNet.shared.is_qq = true
            }
        } else {
            #if DEBUG
            print("qqappid缺失，QQ SDK注册失败")
            #else
            
            #endif
        }
    }
    
    
    /// 系统分享 ⚠️分享优先级：图片 > 链接 > 文本 ⚠️分享文本，不传参数：image、url，其他均可传；分享链接，不传参数：image，其他均可传；分享图片都可传
    /// - Parameters:
    ///   - mode: 分享类型
    ///   NGShareModeSystem = 0, // 系统分享
    ///   NGShareModeQQ,         // QQ分享
    ///   NGShareModeWechat,     // 微信分享
    ///   - title: 标题
    ///   - url: 链接
    ///   - text: 分享的内容，仅QQ和微信模式下传改参数
    ///   - image: 图片
    ///   - previewImage: 预览图片 链接参数http QQ分享
    @objc public class func sdkShare(mode: NGShareMode, title: String? = nil, text: String? = nil, url: String? = nil, image: UIImage? = nil, previewImage: UIImage? = nil){
        
        if mode == .system {
            // 系统分享
            share(title: title, url: url, image: image)
        } else {
            
            let share_title = title ?? ""
            let share_text = text ?? ""
            guard let share_image = image else {
                
                guard let share_url = url else {
                    
                    // 分享文本
                    if mode == .QQ {
                        // QQ
                        shareQQ(title: share_title, text: share_text)
                    } else if mode == .wechat {
                        // 微信
                        shareWechat(title: share_title, text: share_text)
                    }
                    
                    return
                }
                
                // 分享链接
                if mode == .QQ {
                    // QQ
                    shareQQ(title: share_title, text: share_text, url: share_url)
                } else if mode == .wechat {
                    // 微信
                    shareWechat(title: share_title, text: share_text, url: share_url, previewImage: previewImage)
                }
                
                return
            }
            
            // 分享图片
            if mode == .QQ {
                // QQ
                shareQQ(title: share_title, text: share_text, image: share_image, previewImage: previewImage)
            } else if mode == .wechat {
                // 微信
                shareWechat(title: share_title, text: share_text, image: share_image, previewImage: previewImage)
            }
        }
    }
    
    /// 系统分享
    private class func share(title: String? = nil, url: String? = nil, image: UIImage? = nil){
        
        var items = [Any]()
        if title != nil {
            items.append(title!)
        }
        if let URL = URL(string: url ?? "") {
            items.append(URL)
        }
        if image != nil {
            items.append(image!)
        }
        let activety = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activety.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if activityError != nil {
                Totas.show("分享错误", .fail)
            } else if activityType == nil || completed == false {
                Totas.show("分享取消", .info)
            } else {
                Totas.show("分享成功", .success)
            }
        }
        
        NGTool.currentvc().present(activety, animated: true)
    }
    
    /// QQ分享图片
    private class func shareQQ(title: String, text: String, image: UIImage, previewImage: UIImage? = nil){
        
        if (NGNet.shared.is_qq == false) {
            print("QQ未初始化")
            return
        }
        
        if TencentOAuth.iphoneQQInstalled() || TencentOAuth.iphoneTIMInstalled() {
        
            // 图片 最大10M
            let image_data = image.resetSizeOfImageData(maxSize: 10240)
            
            // 缩略图 最大32kb
            let previewData = previewImage?.resetSizeOfImageData(maxSize: 32) ?? image.resetSizeOfImageData(maxSize: 32)
            
            let obj = QQApiImageObject(data: image_data, previewImageData: previewData, title: title, description: text)
            let req = SendMessageToQQReq.init(content: obj)
            QQApiInterface.send(req) // 分享
        } else {
            Totas.show("请检查是否安装QQ或TIM", .info)
        }
    }
    
    /// 微信分享图片
    private class func shareWechat(title: String, text: String, image: UIImage, previewImage: UIImage? = nil){
        
        if (NGNet.shared.is_wechat == false) {
            print("微信未初始化")
            return
        }
        
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
            
            // 图片 最大10M
            guard let image_data = image.resetSizeOfImageData(maxSize: 10240) else {
                print("微信分享图片转换失败")
                return
            }
            
            // 缩略图 最大32kb
            let previewData = previewImage?.resetSizeOfImageData(maxSize: 32) ?? image.resetSizeOfImageData(maxSize: 32)
            
            let obj = WXImageObject()
            obj.imageData = image_data
            
            let msg = WXMediaMessage()
            msg.mediaObject = obj
            msg.title = title
            msg.description = text
            msg.thumbData = previewData
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = msg
            req.scene = 0
            WXApi.send(req) { flag in
                
            }
        } else {
            Totas.show("请检查是否安装微信", .info)
        }
    }
    
    /// QQ分享链接
    private class func shareQQ(title: String, text: String, url: String){
        
        if (NGNet.shared.is_qq == false) {
            print("QQ未初始化")
            return
        }
        
        if TencentOAuth.iphoneQQInstalled() || TencentOAuth.iphoneTIMInstalled() {
            
            guard let share_url = URL(string: url) else {
                Totas.show("分享的链接无效", .info)
                return
            }
            
            guard let path = Bundle.sdkBundle()?.path(forResource: "icon_logo", ofType: "png") else { return print("QQ分享缩略图路径错误") }
            let preview_url = URL(string: path)
            let obj = QQApiURLObject(url: share_url, title: title, description: text, previewImageURL: preview_url, targetContentType: .news)
            let req = SendMessageToQQReq.init(content: obj)
            QQApiInterface.send(req) // 分享
        } else {
            Totas.show("请检查是否安装QQ或TIM", .info)
        }
    }
    
    /// 微信分享链接
    private class func shareWechat(title: String, text: String, url: String, previewImage: UIImage? = nil){
        
        if (NGNet.shared.is_wechat == false) {
            print("微信未初始化")
            return
        }
        
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
            let obj = WXWebpageObject()
            obj.webpageUrl = url
            
            let msg = WXMediaMessage()
            msg.title = title
            msg.description = text
            msg.mediaObject = obj
            
            let preview_image = previewImage ?? UIImage.image("icon_logo")
            msg.thumbData = preview_image?.resetSizeOfImageData(maxSize: 32)
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = msg
            req.scene = 0
            WXApi.send(req) { flag in
                
            }
        } else {
            Totas.show("请检查是否安装微信", .info)
        }
    }
    
    /// QQ分享文本
    private class func shareQQ(title: String, text: String){
        
        if (NGNet.shared.is_qq == false) {
            print("QQ未初始化")
            return
        }
        
        if TencentOAuth.iphoneQQInstalled() || TencentOAuth.iphoneTIMInstalled() {
            
            let obj = QQApiTextObject(text: text)
            obj?.title = title
            let req = SendMessageToQQReq.init(content: obj)
            QQApiInterface.send(req) // 分享
        } else {
            Totas.show("请检查是否安装QQ或TIM", .info)
        }
    }
    
    /// 微信分享文本
    private class func shareWechat(title: String, text: String){
        
        if (NGNet.shared.is_wechat == false) {
            print("微信未初始化")
            return
        }
        
        if WXApi.isWXAppInstalled() && WXApi.isWXAppSupport() {
            let obj = WXTextObject()
            obj.contentText = text
            
            let msg = WXMediaMessage()
            msg.title = title
            msg.description = text
            msg.mediaObject = obj
            
            let req = SendMessageToWXReq()
            req.bText = false
            req.message = msg
            req.scene = 0
            WXApi.send(req) { flag in
                
            }
        } else {
            Totas.show("请检查是否安装微信", .info)
        }
    }
}
