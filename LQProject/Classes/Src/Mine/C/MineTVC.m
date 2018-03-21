//
//  MineTVC.m
//  LQProject
//
//  Created by JW on 2016/12/1.
//  Copyright © 2016年 jacli. All rights reserved.
//

#import "MineTVC.h"

@interface MineTVC ()

@end

@implementation MineTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"mine";
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    PageRout_Maneger.currentNaviVC = self.navigationController;
}

@end
