//
//  QDCommonTableViewController.m
//  qmuidemo
//
//  Created by ZhoonChen on 15/4/13.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QDCommonTableViewController.h"

@interface QDCommonTableViewController ()

@end

@implementation QDCommonTableViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APPColor_BackgroudView;
    self.tableView.backgroundColor = APPColor_BackgroudView;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

}

- (void)didInitialized {
    [super didInitialized];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleThemeChangedNotification:) name:QDThemeChangedNotification object:nil];
    self.extendedLayoutIncludesOpaqueBars = NO;

    
}

- (void)dealloc {
    [kNotificationCenter removeObserver:self];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)handleThemeChangedNotification:(NSNotification *)notification {
    NSObject<QDThemeProtocol> *themeBeforeChanged = notification.userInfo[QDThemeBeforeChangedName];
    themeBeforeChanged = [themeBeforeChanged isKindOfClass:[NSNull class]] ? nil : themeBeforeChanged;
    
    NSObject<QDThemeProtocol> *themeAfterChanged = notification.userInfo[QDThemeAfterChangedName];
    themeAfterChanged = [themeAfterChanged isKindOfClass:[NSNull class]] ? nil : themeAfterChanged;
    
    [self themeBeforeChanged:themeBeforeChanged afterChanged:themeAfterChanged];
}

#pragma mark - <QDChangingThemeDelegate>

- (void)themeBeforeChanged:(NSObject<QDThemeProtocol> *)themeBeforeChanged afterChanged:(NSObject<QDThemeProtocol> *)themeAfterChanged {
    [self.tableView reloadData];
}
#pragma mark - 添加下拉刷新
- (void)addPullRefreshWithBlock:(void(^)(void))block {
    @weakify(self)
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        self.tableView.mj_footer.hidden = NO;
        if (block) {
            block();
        }
    }];
    ((MJRefreshNormalHeader*)self.tableView.mj_header).lastUpdatedTimeLabel.hidden = YES;
}

#pragma mark - 上拉加载更多
- (void)addLoadingMoreWithBlock:(void(^)(void))block {
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (block) {
            block();
        }
    }];
    // Set footer
    self.tableView.mj_footer = footer;
    footer.stateLabel.hidden = YES;//隐藏刷新时显示文字
}

- (void)endRefreshWithFooterHidden {
    [self.tableView.mj_footer endRefreshing];
    //通知已经全部加载完毕
    [self.tableView.mj_footer endRefreshingWithNoMoreData];
    //    self.tableView.mj_footer.hidden = YES;
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    return YES;
}

@end
