//
//  HomeTVC.m
//  LQProject
//
//  Created by JW on 2016/12/1.
//  Copyright © 2016年 jacli. All rights reserved.
//

#import "HomeTVC.h"


@interface HomeTVC ()

@end

@implementation HomeTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"home";
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    PageRout_Maneger.currentNaviVC = self.navigationController;
}


@end
