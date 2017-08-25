//
//  Tool.m
//  LawChatForLawyer
//
//  Created by lawchat on 15/5/20.
//  Copyright (c) 2015   jackli. All rights reserved.
//

#import "Tool.h"


#import "MSJSONResponseSerializerWithData.h"
#import "LoginVC.h"
#import "RxWebViewController.h"
#import "JSONKit.h"
#import <sys/utsname.h>

@implementation Tool

+ (void)requestApiWithParams:(NSDictionary *)params andRequestUrl:(NSString *)url completedBlock:(void(^)(NSDictionary *dic,bool isSuccess))block
{
    
    // 参数的封装
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //必传参数
    parameters[@"version"] = App_Version;
    parameters[@"channel"] = @0;
    
    //    //参数去emoji表情
    //    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    //    for (NSString *key in params) {
    //        NSString *string = params[key];
    //        paramDict[key] = [self stringContainsEmoji:string];
    //    }
    
    
    //追加参数
    [parameters addEntriesFromDictionary:params];
    
    // url 地址
    NSString *URL = [NSString stringWithFormat:@"%@%@",UserApiUrl,url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer.HTTPShouldHandleCookies = YES;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    manager.responseSerializer = [MSJSONResponseSerializerWithData serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    
    [manager POST:URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        LQLog(@"%@ %@ -----API:%@",responseObject,manager.requestSerializer.HTTPRequestHeaders,url);
        NSDictionary *dic = [responseObject objectFromJSONString];
        if ([dic[@"code"] integerValue] > 0) {
            block(dic,YES);
        }
        else {
            block(dic,NO);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LQLog(@"Error: %@ ----- API:%@", task.response,url);
        
        NSDictionary *dic = [[error.userInfo objectForKey:@"body"] objectFromJSONString];
        if ([dic objectForKey:@"code"]) {
            [self checkError:dic];
            block(dic,NO);
        }else{
            block(nil,NO);
        }
    }];
    [manager invalidateSessionCancelingTasks:NO];
}

+(void)checkError:(NSDictionary*)dict
{
    if ([dict objectForKey:@"code"]) {
        if([dict[@"code"] intValue] == -1006)
        {
            //未登录去登录
            [self requestLoginMethodWithCompletedBlock:nil noConnet:nil];
        }
    }
    
}
/**
 *  自动登录
 *
 *  @param block 是否登录成功
 */
+ (void)requestLoginMethodWithCompletedBlock:(void(^)(bool isSuccess))block noConnet:(void(^)(void))noConnet{
    
    if ([UserDefaults objectForKey:@"userName"] && [UserDefaults objectForKey:@"password"]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"phone"] = [UserDefaults objectForKey:@"userName"];
        params[@"code"] = [UserDefaults objectForKey:@"password"];
        
        [Tool requestApiWithParams:params andRequestUrl:@"checkLoginSMSCode" completedBlock:^(NSDictionary *dic, bool isSuccess) {
            if(dic)
            {
                switch ([dic[@"code"] intValue]) {
                    case 1:
                    {
                        /**
                         *  登录成功
                         */
                        //用户中心
                        
                        
                        User_Center.ID     = params[@"phone"];
                        User_Center.pass = params[@"code"];
                        
                        /**
                         *  存档
                         */
                        [UserCenter resetUserCenterWithDictionary:dic[@"data"]];
                        if (block) {
                            block(YES);
                        }
                        //                        [Tool pushTokenWithBlock:nil];
                        
                    }
                        break;
                    default:
                    {
                        /**
                         *  跳转登录界面
                         */
                        if (block) {
                            block(NO);
                        }
                        
                        [UserCenter clearUserCenter];
                        [UserDefaults setObject:nil forKey:@"password"];
                        
                    }
                        break;
                }
                [App_Delegate changeWindowRootVC];
            }else{
                /**
                 *  请求网络异常
                 */
                if (noConnet) {
                    noConnet();
                }
            }
        }];
    } else {
        /**
         *  跳转登录界面
         */
        if (block) {
            block(NO);
        }
        [UserCenter clearUserCenter];
        [UserDefaults setObject:nil forKey:@"password"];
        [App_Delegate changeWindowRootVC];
    }
}

#pragma mark - 点击关于账户的操作检测是否登录（伴随hud）
+ (void)checkLoginAndShowHUDWithSuccessBlock:(void(^)(void))successBlock {
    if ([UserCenter checkIsLogin]) {
        if (successBlock) {
            successBlock();
        }
    }else{
        NSUserDefaults *ud = UserDefaults;
        if (![ud objectForKey:@"userName"] || ![ud objectForKey:@"password"]) {
            [App_Delegate changeWindowRootVC];
        }else{
            [SVProgressHUD show];
            [Tool requestLoginMethodWithCompletedBlock:^(bool isSuccess) {
                if (isSuccess) {
                    [SVProgressHUD dismiss];
                    if (successBlock) {
                        successBlock();
                    }
                }
            } noConnet:^{
                [SVProgressHUD showErrorWithStatus:@"网络异常"];
            }];
        }
    }
}

#pragma mark - push网页
+ (void)gotoWebWithUrl:(NSString*)url inNavigationVC:(UINavigationController*)navigationVC{
    
    RxWebViewController *VC = [[RxWebViewController alloc] initWithUrl:[NSURL URLWithString:url]];

    if (navigationVC) {
        [navigationVC pushViewController:VC animated:YES];
    } else {
        AppDelegate *apd = App_Delegate;
        [apd.customNavVC pushViewController:VC animated:YES];
    }
    
}
@end
