//
//  NGInfo.swift
//  NGSDK
//
//  Created by Paul on 2023/3/1.
//

import Foundation

@objc public class Role: NSObject{
    
    /// 角色ID
    @objc public var roleID: String?
    
    /// 角色名称
    @objc public var roleName: String?
    
    /// 角色等级
    @objc public var roleLevel: String?
    
    /// 服务器ID
    @objc public var serverId: String?
    
    /// 服务器名称
    @objc public var serverName: String?
    
    /// 支付等级
    @objc public var payLevel: String?
}

@objc public class Order: NSObject{
    
    /// cp订单号
    @objc public var cpOrder: String?
    
    /// 价格
    @objc public var cost: String?
    
    /// 商品ID
    @objc public var goodsID: String?
    
    /// 商品名称
    @objc public var goodsName: String?
    
    /// 透传参数
    @objc public var extends: String?
    
    /// 支付回调，SDK后台填写，这里则默认不填
    @objc public var notifyURL: String?
    
    /// 订单号
    var order_id: String?
}
