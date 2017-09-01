//
//  AppDelegate.h
//  PublicLawyerChat
//
//  Created by  jackli on 15/5/20.
//  Copyright (c) 2015   jackli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;


@property(nonatomic, strong) UINavigationController *loginVC;

/**
 *  当前页面的NavigationController
 */
@property(nonatomic, weak) UINavigationController *customNavVC;

/**
 *  退出登录返回主页面
 */
- (void)exitLoginGotoRoot;


/**
 *  改变根界面
 */
- (void)changeWindowRootVC;


@property(nonatomic,assign) BOOL isRunning;

@end

