//
//  HomeTVC.m
//  LQProject
//
//  Created by JW on 2016/12/1.
//  Copyright © 2016年 jacli. All rights reserved.
//

#import "HomeTVC.h"

#import "ADView.h"

@interface HomeTVC ()

@end

@implementation HomeTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"home";
    
    
    //设置显示广告
//    if (!Url_Json.isShowedAd) {
//        [self setupADView];
//        Url_Json.isShowedAd = YES;
//    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AppDelegate *apd = App_Delegate;
    apd.customNavVC = self.navigationController;
}



- (void)setupADView {
    NSString *imageUrl = @"";
    NSString *adURL = @"";
    ADView *adView = [[ADView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds withImageUrl:imageUrl withADUrl:adURL withClickBlock:^(NSString *clikADUrl) {
        
        [Tool gotoWebWithUrl:clikADUrl inNavigationVC:self.navigationController];
        
    }];
    
    [adView show];
}
@end
