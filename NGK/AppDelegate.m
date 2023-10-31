//
//  AppDelegate.m
//  NGK
//
//  Created by Paul on 2023/2/10.
//

#import "AppDelegate.h"
#import "NGMainVC.h"
#import "NGK-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
//    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[NGMainVC new]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[NGSwiftVC new]];
    
    return YES;
}


@end
