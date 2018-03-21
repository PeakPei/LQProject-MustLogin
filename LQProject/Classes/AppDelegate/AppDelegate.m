//
//  AppDelegate.m
//  PublicLawyerChat
//
//  Created by   on 15/5/20.
//  Copyright (c) 2015   jackli. All rights reserved.
//
#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "GuideViewController.h"
//振动
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 向苹果注册推送，获取deviceToken并上报
    [self registerAPNS:application];
    [self initAPPWithOptions:launchOptions];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
}
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [UserCenter save];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
}
- (void)applicationWillTerminate:(UIApplication *)application {
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return YES;
}

#pragma mark - 初始化应用配置
- (void)initAPPWithOptions:(NSDictionary *)launchOptions{
    // QD自定义的全局样式渲染
    [QDCommonUI renderGlobalAppearances];
    
    [self initThirdSDKWithOptions:launchOptions];
    
    [self initSVProgressHUD];
    
    [self initWindow];
}

#pragma mark - 设置SVP样式
- (void)initSVProgressHUD {
    [SVProgressHUD setMinimumDismissTimeInterval:0.8];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    //    背景图层的颜色
    [SVProgressHUD setBackgroundColor:APPColor_HudBackground];
    //    文字的颜色
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
}

#pragma mark - 初始化启动窗口
- (UIWindow *)window {
    return PageRout_Maneger.window;
}
- (void)initWindow {
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"upVersion"] isEqualToString:App_Version]) {
        //打开引导页
        PageRout_Maneger.window.rootViewController = [[GuideViewController alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:App_Version forKey:@"upVersion"];
    } else {
        if ([UserCenter checkIsLogin]) {
            //本地已经登录过，获取用户信息直接
            PageRout_Maneger.window.rootViewController = [PageRout_Maneger APPMainVC];
        } else {
            [PageRout_Maneger gotoLoginVC];
        }
    }
    [PageRout_Maneger.window makeKeyAndVisible];
}

#pragma mark - 初始化第三方SDK
- (void)initThirdSDKWithOptions:(NSDictionary *)launchOptions{
    
}
#pragma mark APNs Register
/**
 *    向APNs注册，获取deviceToken用于推送
 *
 *    @param     application
 */
- (void)registerAPNS:(UIApplication *)application {
    float systemVersionNum = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersionNum >= 10.0) {
        // iOS 10 notifications
        UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        // 请求推送权限
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // granted
                // 向APNs注册，获取deviceToken(这个方法会调用注册成功或失败的回调方法)
                [[RACScheduler mainThreadScheduler] schedule:^{
                    [application registerForRemoteNotifications];
                }];
                
            } else {
            }
        }];
    } else if (systemVersionNum >= 8.0) {
        // iOS 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge categories:nil]];
        [application registerForRemoteNotifications];
#pragma clang diagnostic pop
    }
}

/*
 *  APNs注册成功回调，将返回的deviceToken上传到CloudPush服务器
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

}

/*
 *  APNs注册失败回调
 */
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    LQLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

#pragma mark - iOS10及以上专用：触发通知动作时回调，比如点击、删除通知和点击自定义action(应用外点击推送)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    completionHandler();
}

#pragma mark - iOS10及以上专用:APP处于前台收到推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    completionHandler(UNNotificationPresentationOptionAlert);
}

#pragma mark - iOS7~10通用：当没有实现对应系统的方法时无论APP在前台或后台都会调用
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        return;
    } else {
        //处理
    }
}

@end
