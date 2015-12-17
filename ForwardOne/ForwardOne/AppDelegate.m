//
//  AppDelegate.m
//  ForwardOne
//
//  Created by 杨波 on 15/4/7.
//  Copyright (c) 2015年 杨波. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

//#import "staticUserInfo.h"
#import "newFeatureViewController.h"
#import "YBWebSocketManager.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    YBWebSocketManager *socketManager = [YBWebSocketManager sharedInstance];
    
    //判断网络状态  是否加载图片
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"www.baidu.com"]];
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //设置网络状态改变后执行的block
        
        //4种状态(未知,不可达,GPRS,WiFi)
        /*
         AFNetworkReachabilityStatusUnknown
         AFNetworkReachabilityStatusNotReachable
         AFNetworkReachabilityStatusReachableViaWWAN
         AFNetworkReachabilityStatusReachableViaWiFi
         */
        NSLog(@"当前网络状态为 %@",@[@"不可达",@"使用GPRS",@"使用WiFi"][status]);
        if(status == AFNetworkReachabilityStatusReachableViaWiFi)
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:DataSetting2];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:DataSetting2];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }];
    
    //开始启动网络状态的监听
    [manager.reachabilityManager startMonitoring];
    
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //判断是否app第一次启动
    NSString *key = (NSString *)kCFBundleVersionKey;
    //从Info.plist中取出版本号
    NSString *version = [NSBundle mainBundle].infoDictionary[key];
    
    //从沙盒中取出上次存储的版本号
    NSString *saveVersion = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    NSLog(@"**********存储的版本号的%@",saveVersion);
    
    if([version isEqualToString:saveVersion])
    {
        //不是第一次使用
        ViewController *rvc = [[ViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rvc];
        self.window.rootViewController = nav;
    
    }
    else
    {
        //是第一次使用
        //第一次使用新版本 将版本号写入沙盒
        application.statusBarHidden = YES;
        
        [[NSUserDefaults standardUserDefaults]setObject:version forKey:key];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        self.window.rootViewController = [[newFeatureViewController alloc]init];
        
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
