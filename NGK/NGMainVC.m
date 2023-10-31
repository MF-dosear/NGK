//
//  NGMainVC.m
//  NGK
//
//  Created by Paul on 2023/2/13.
//

#import "NGMainVC.h"
#import <NGSDK/NGSDK.h>

@interface NGMainVC ()

@property (nonatomic, copy) NSArray *list;

@end

@implementation NGMainVC

- (NSArray *)list{
    if (_list == nil){
        _list = @[
            @"登录",
            @"上传角色",
            @"支付",
            @"登出",
            @"系统分享",
            @"QQ分享图片(优先级高)",
            @"微信分享图片(优先级高)",
            @"QQ分享链接(优先级中)",
            @"微信分享链接(优先级中)",
            @"QQ分享文本(优先级低)",
            @"微信分享文本(优先级低)",
            @"Safari打开网页",
            @"绑定手机号",
            @"测试页面"
        ];
    }
    return _list;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Swift游戏SDK";
    
    [NGSDK sdkInitWithApp_id:@"1000001" app_key:@"48f2bd0d7ab066687f0ab2b85241ae34" link:@"cwdzz" appld_id:@"1670290308" jy_app_key:@"17beb89b4554b40dcc0e0f8fa1ec2152" result:^(BOOL flag) {
        
        NSLog(@"初始化：flag = %d", flag);
    }];
    
    [NGSDK sdkLogoutBackWithResult:^(BOOL flag) {
        NSLog(@"退出登录：flag = %d", flag);
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.list[indexPath.item];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UIImage *image = [UIImage imageNamed:@"image"];
    UIImage *previewImage = [UIImage imageNamed:@"previewImage"];
    NSString *url = @"https://www.baidu.com";
    
    Role *role = [[Role alloc] init];
    role.roleID     = @"角色ID";
    role.roleName   = @"角色名称";
    role.roleLevel  = @"角色等级";
    role.serverId   = @"服务器ID";
    role.serverName = @"服务器名称";
    role.payLevel   = @"支付等级";
    
    Order *order = [[Order alloc] init];
    order.cpOrder   = @"cp订单号";
    order.cost      = @"价格";
    order.goodsID   = @"商品ID";
    order.goodsName = @"商品名称";
    order.extends   = @"透传参数";
    order.notifyURL = @"回调地址（可传参数";
    
    switch (indexPath.item) {
        case 0: [NGSDK sdkLoginWithAutomatic:true result:^(BOOL flag, NSString * _Nullable uid, NSString * _Nullable sid, NSString * _Nullable user_name) {
            
            NSLog(@"登录：flag = %d, uid = %@, sid = %@, user_name = %@", flag, uid, sid, user_name);
        }];
            break;
        case 1: [NGSDK sdkSubmitRoleWithRole:role result:^(BOOL flag) {
            NSLog(@"上传角色：flag = %d", flag);
        }];
            break;
        case 2: [NGSDK sdkPayWithRole:role order:order result:^(BOOL flag) {
            NSLog(@"支付：flag = %d", flag);
        }];
            break;
        case 3: [NGSDK sdkLogout];
            break;
        case 4: [NGSDK sdkShareWithMode:NGShareModeSystem title:@"标题" text:@"内容" url:nil image:image previewImage:nil];
            break;
        case 5: [NGSDK sdkShareWithMode:NGShareModeQQ title:@"标题" text:@"内容" url:nil image:image previewImage:previewImage];
            break;
        case 6: [NGSDK sdkShareWithMode:NGShareModeWechat title:@"标题" text:@"内容" url:nil image:image previewImage:previewImage];
            break;
        case 7: [NGSDK sdkShareWithMode:NGShareModeQQ title:@"标题" text:@"内容" url:url image:nil previewImage:nil];
            break;
        case 8: [NGSDK sdkShareWithMode:NGShareModeWechat title:@"标题" text:@"内容" url:url image:nil previewImage:previewImage];
            break;
        case 9: [NGSDK sdkShareWithMode:NGShareModeQQ title:@"标题" text:@"内容" url:nil image:nil previewImage:nil];
            break;
        case 10: [NGSDK sdkShareWithMode:NGShareModeWechat title:@"标题" text:@"内容" url:nil image:nil previewImage:nil];
            break;
        case 11: [NGSDK sdkOpenUrlWithUrl:@"https://www.baidu.com"];
            break;
        case 12: [NGSDK sdkBindPhone];
            break;
//        case 13: [NGSDK sdkShowTestVC];
//            break;
        default:
            break;
    }
}

@end
