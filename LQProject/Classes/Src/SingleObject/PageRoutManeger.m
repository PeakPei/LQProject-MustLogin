//
//  PageRoutManeger.m
//  LQProject
//
//  Created by Juice on 2018/3/21.
//  Copyright © 2018年 jacli. All rights reserved.
//

#import "PageRoutManeger.h"

#import "QDNavigationController.h"
#import "LoginVC.h"
#import "LoginVC.h"
#import "HomeTVC.h"
#import "MineTVC.h"

static PageRoutManeger *_sharedPageRoutManeger;

@implementation PageRoutManeger
#pragma mark - 获得单例
+ (instancetype) sharedInstance {
    
    static dispatch_once_t token;
    
    dispatch_once(&token,^{
        if (!_sharedPageRoutManeger) {
            _sharedPageRoutManeger = [[PageRoutManeger alloc] init];
        }
    });
    return _sharedPageRoutManeger;
}

- (UIWindow *)window {
    if (!_window) {
        //创建window
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.backgroundColor = APPColor_BackgroudView;
    }
    return _window;
}

#pragma mark - 跳转到登录页面
- (void)gotoLoginVC {
    
    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LoginVC *loginVC = [SB instantiateViewControllerWithIdentifier:@"LoginVC"];
    
    //强制登录型切换根视图
    [UIView transitionWithView:self.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [self.window setRootViewController:[[UINavigationController alloc] initWithRootViewController:loginVC]];
        [UIView setAnimationsEnabled:oldState];
    } completion:NULL];
    
    //可选型跳转
//    [self.currentNaviVC pushViewController:loginVC animated:YES]
}
#pragma mark - 退出登录返回主页面（退出登录跳转到登录页面）
- (void)exitToLoginVC {
    [UserCenter clearUserCenter];
    [self gotoLoginVC];
}
#pragma mark - 初始化主要得APP根视图控制器TabBarVC
- (QDTabBarViewController *)APPMainVC {
    QDTabBarViewController *tabBarViewController = [[QDTabBarViewController alloc] init];
    
    HomeTVC *homeTVC = [[HomeTVC alloc] init];
    homeTVC.hidesBottomBarWhenPushed = NO;
    QDNavigationController *homeNavController = [[QDNavigationController alloc] initWithRootViewController:homeTVC];
    homeNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"QMUIKit" image:[UIImageMake(@"icon_tabbar_uikit") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_uikit_selected") tag:0];

    MineTVC *mineTVC = [[MineTVC alloc] init];
    mineTVC.hidesBottomBarWhenPushed = NO;
    QDNavigationController *mineNavController = [[QDNavigationController alloc] initWithRootViewController:mineTVC];
    mineNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"Components" image:[UIImageMake(@"icon_tabbar_component") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"icon_tabbar_component_selected") tag:1];
    
    // window root controller
    tabBarViewController.viewControllers = @[homeNavController, mineNavController];
    
    return tabBarViewController;
}

#pragma mark - 改变根界面（登录成功进入APP，强制登录型使用，可选登录型只需要登录成功后pop掉登录页面即可）
- (void)changeWindowRootToMainVC {
    [UIView transitionWithView:self.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [self.window setRootViewController:[self APPMainVC]];
        [UIView setAnimationsEnabled:oldState];
    } completion:NULL];
}

@end
