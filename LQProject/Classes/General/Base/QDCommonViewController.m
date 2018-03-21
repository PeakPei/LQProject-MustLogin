//
//  QDCommonViewController.m
//  qmuidemo
//
//  Created by ZhoonChen on 15/4/13.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QDCommonViewController.h"

@implementation QDCommonViewController

- (void)didInitialized {
    [super didInitialized];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeChangedNotification:) name:QDThemeChangedNotification object:nil];

    self.extendedLayoutIncludesOpaqueBars = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APPColor_BackgroudView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 打开键盘补偿视图
    [self.view openKeyboardOffsetView];
    self.view.keyboardGap = 10; // 如果需要自定义键盘与第一响应者之间的间隙，则设置此属性，默认为5
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 关闭键盘补偿视图
    [self.view closeKeyboardOffsetView];
}
- (void)dealloc {
    [kNotificationCenter removeObserver:self];
}
- (void)handleThemeChangedNotification:(NSNotification *)notification {
    NSObject<QDThemeProtocol> *themeBeforeChanged = notification.userInfo[QDThemeBeforeChangedName];
    NSObject<QDThemeProtocol> *themeAfterChanged = notification.userInfo[QDThemeAfterChangedName];
    [self themeBeforeChanged:themeBeforeChanged afterChanged:themeAfterChanged];
}

#pragma mark - <QDChangingThemeDelegate>

- (void)themeBeforeChanged:(NSObject<QDThemeProtocol> *)themeBeforeChanged afterChanged:(NSObject<QDThemeProtocol> *)themeAfterChanged {
    
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    return YES;
}

@end
