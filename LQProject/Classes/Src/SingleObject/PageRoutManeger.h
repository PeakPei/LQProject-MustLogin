//
//  PageRoutManeger.h
//  LQProject
//
//  Created by Juice on 2018/3/21.
//  Copyright © 2018年 jacli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QDTabBarViewController.h"

#define PageRout_Maneger [PageRoutManeger sharedInstance]

@interface PageRoutManeger : NSObject

///根Window
@property (strong, nonatomic) UIWindow *window;

/// 记录APP当前浏览页面的NavigationController，用于随时push页面使用
@property(nonatomic, weak) UINavigationController *currentNaviVC;

#pragma mark - 获得单例
+ (instancetype)sharedInstance;
#pragma mark - 跳转到登录页面
- (void)gotoLoginVC;
#pragma mark - 退出登录返回主页面（退出登录跳转到登录页面）
- (void)exitToLoginVC;
#pragma mark - 初始化主要得APP根视图控制器TabBarVC
- (QDTabBarViewController*)APPMainVC;
#pragma mark - 改变根界面（登录成功进入APP，强制登录型使用，可选登录型只需要登录成功后pop掉登录页面即可）
- (void)changeWindowRootToMainVC;

@end
