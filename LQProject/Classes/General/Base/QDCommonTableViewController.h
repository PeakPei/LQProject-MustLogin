//
//  QDCommonTableViewController.h
//  qmuidemo
//
//  Created by ZhoonChen on 15/4/13.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QDThemeProtocol.h"

@interface QDCommonTableViewController : QMUICommonTableViewController <QDChangingThemeDelegate>

/**
 添加下拉刷新
 */
- (void)addPullRefreshWithBlock:(nullable void(^)(void))block;

/**
 添加上拉加载更多
 
 @param block 上拉加载回调
 */
- (void)addLoadingMoreWithBlock:(nullable void(^)(void))block;

/**
 停止上拉加载更多并隐藏footer
 */
- (void)endRefreshWithFooterHidden;

@end
