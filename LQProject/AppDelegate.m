//
//  AppDelegate.m
//  PublicLawyerChat
//
//  Created by   on 15/5/20.
//  Copyright (c) 2015   jackli. All rights reserved.
//
#import "AppDelegate.h"


#import "GuideViewController.h"

#import "LoginVC.h"
#import "HomeTVC.h"
#import "MineTVC.h"

//振动
#import <AudioToolbox/AudioToolbox.h>
#import "QMUIConfigurationTemplate.h"
#import "QDTabBarViewController.h"
#import "QDNavigationController.h"



@interface AppDelegate ()

@property(nonatomic, strong) QDTabBarViewController *rootViewController;
@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    // 应用 QMUI Demo 皮肤
    NSString *themeClassName = [[NSUserDefaults standardUserDefaults] stringForKey:QDSelectedThemeClassName] ?: NSStringFromClass([QMUIConfigurationTemplate class]);
    [QDThemeManager sharedInstance].currentTheme = [[NSClassFromString(themeClassName) alloc] init];
    
    // QD自定义的全局样式渲染
    [QDCommonUI renderGlobalAppearances];
    
    // 预加载 QQ 表情，避免第一次使用时卡顿（可选）
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [QMUIQQEmotionManager emotionsForQQ];
    });
    
    
    // 向苹果注册推送，获取deviceToken并上报
    [self registerAPNS:application];
    
    
    [self _initAPPWithOptions:launchOptions];

    return YES;
}

/**
 *  初始化应用配置
 */
- (void)_initAPPWithOptions:(NSDictionary *)launchOptions{

    
    [self initSVProgressHUD];
    
    [self _initThirdSDKWithOptions:launchOptions];
    
    [self _initWindow];
    
    [self _initWebUserAgent];
    
    [Tool requestLoginMethodWithCompletedBlock:nil noConnet:nil];
    
}

- (void)initSVProgressHUD {
    [SVProgressHUD setMinimumDismissTimeInterval:1.0];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    //    背景图层的颜色
    
    [SVProgressHUD setBackgroundColor:MyColor_HudBackground];
    //    文字的颜色
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
}

/**
 *  初始化启动窗口
 */
- (void)_initWindow{
    

    [self _initLoginViewController];
    [self _initRootViewController];
    /**
     *  根据版本号区别开机选项
     *
     *  @param objectForKey:@"upVersion"]] 上一个版本号
     *
     *  @return 引导页：主界面
     */
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"ifFirstOpen"] isEqualToString:App_Version])
    {
        GuideViewController *vc = [[GuideViewController alloc] init];
        
        self.window.rootViewController = vc;
        [[NSUserDefaults standardUserDefaults] setObject:App_Version forKey:@"ifFirstOpen"];
    } else {
        
        /**
         *  自动登录
         */
        
        [self changeWindowRootVC];
    }
    
    
    [self.window makeKeyAndVisible];
}

/**
 *  设置webView 的 userAgent
 */
- (void)_initWebUserAgent {
//    NSString *newAgent = [NSString stringWithFormat:@"Mozilla/5.0 (iPhone; CPU iPhone OS %@ like Mac OS X ; LawChat Build/%@) AppleWebKit/601.1.46 (KHTML, like Gecko) Version/9.0 Mobile/13B143 Safari/601.1",CurrentSystemVersion,App_Version];
//    
//    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:newAgent, @"UserAgent", nil];
//    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
}


/**
 *  初始化主界面
 */
- (void)_initRootViewController {
    QDTabBarViewController *tabBarViewController = [[QDTabBarViewController alloc] init];
    
    // QMUIKit
    HomeTVC *homeTVC = [[HomeTVC alloc] init];
    homeTVC.hidesBottomBarWhenPushed = NO;
    QDNavigationController *homeNavController = [[QDNavigationController alloc] initWithRootViewController:homeTVC];
    homeNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"QMUIKit" image:[UIImageMake(@"icon_tabbar_uikit") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_uikit_selected") tag:0];
    
    // UIComponents
    MineTVC *mineTVC = [[MineTVC alloc] init];
    mineTVC.hidesBottomBarWhenPushed = NO;
    QDNavigationController *mineNavController = [[QDNavigationController alloc] initWithRootViewController:mineTVC];
    mineNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"Components" image:[UIImageMake(@"icon_tabbar_component") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_component_selected") tag:1];
    
    // window root controller
    tabBarViewController.viewControllers = @[homeNavController, mineNavController];
    self.rootViewController = tabBarViewController;
    
    
    //创建window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = MyColor_BackgroudView;
    self.window.rootViewController = self.rootViewController;
}

/**
 *  创建登录界面
 */
- (void)_initLoginViewController {
    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LoginVC *loginVC = [SB instantiateViewControllerWithIdentifier:@"LoginVC"];
    _loginVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
}

/**
 *  切换根视图界面
 */
- (void)changeWindowRootVC {

    [RACObserve(User_Center , userAuditState) subscribeNext:^(id x) {
        if (User_Center.ID && User_Center.pass && User_Center.userAuditState.integerValue == 1) {
            if (self.window.rootViewController == _loginVC) {
                
                [UIView transitionWithView:self.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    BOOL oldState = [UIView areAnimationsEnabled];
                    [UIView setAnimationsEnabled:NO];
                    [self.window setRootViewController:_rootViewController];
                    [UIView setAnimationsEnabled:oldState];
                } completion:NULL];
            }
        } else {
            if (self.window.rootViewController == _rootViewController) {
                [UIView transitionWithView:self.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    BOOL oldState = [UIView areAnimationsEnabled];
                    [UIView setAnimationsEnabled:NO];
                    [self.window setRootViewController:_loginVC];
                    [UIView setAnimationsEnabled:oldState];
                } completion:NULL];
            }
        }
    }];
}

/**
 *  初始化第三方SDK
 *
 *  @param launchOptions 启动options
 */
- (void)_initThirdSDKWithOptions:(NSDictionary *)launchOptions{
    
    
}


#pragma mark APNs Register
/**
 *    @brief    注册苹果推送，获取deviceToken用于推送
 *
 *    @param     application
 */
- (void)registerAPNS:(UIApplication *)application {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [application registerForRemoteNotifications];
    }
    else {
        // iOS < 8 Notifications
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
}

/*
 *  苹果推送注册成功回调，将苹果返回的deviceToken上传到CloudPush服务器
 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

}

/*
 *  苹果推送注册失败回调
 */
//如果deviceToken获取不到会进入此事件
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    //如果注册不成功，打印错误信息，可以在网上找到对应的解决方案
    //如果注册成功，可以删掉这个方法
    LQLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    

    if (_isRunning) {
        return;
    }
    
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    jsonDict[@"title"] = userInfo[@"aps"][@"alert"];
    switch ([jsonDict[@"type"] intValue]) {
        case 1:
        {
            
            //强制下线
            if ([UserCenter checkIsLogin]) {
                [self exitLoginGotoRoot];
//                [UtilsApi showAlertWithMessage:jsonDict[@"title"] inViewController:[UtilsApi getCurrentVC] okBlock:nil];

            }
        }
            break;
        default:
            break;
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    _isRunning = NO;
    [UserCenter save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [Tool requestLoginMethodWithCompletedBlock:nil noConnet:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    _isRunning = YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    
    return YES;
}

#pragma mark - 退出登录返回主页
- (void)exitLoginGotoRoot {
    /**
     *  清除数据返回主页面
     */
    //    [Tool unbindAccountToAliPush:^(bool isSuccess) {
    //
    //    }];

    [UserCenter clearUserCenter];
    
    [self _initWindow];
}


@end
