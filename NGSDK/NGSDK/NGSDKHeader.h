//
//  NGSDKHeader.h
//  NGSDK
//
//  Created by Paul on 2023/2/24.
//

#ifndef Header_h
#define Header_h

#import <Foundation/Foundation.h>

/// 分享类型
typedef NS_ENUM(NSUInteger, NGShareMode) {
    NGShareModeSystem = 0, // 系统分享 每个平台有差异
    NGShareModeQQ,         // QQ分享
    NGShareModeWechat,     // 微信分享
};

/// 微信头文件
#import "WXApi.h"
#import "WXApiObject.h"

/// QQ头文件
#import "TencentOpenApiUmbrellaHeader.h"

#import "SVProgressHUD.h"

#endif /* Header_h */

