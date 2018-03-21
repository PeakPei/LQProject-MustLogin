//
//  Tool.m
//  LawChatForLawyer
//
//  Created by lawchat on 15/5/20.
//  Copyright (c) 2015   jackli. All rights reserved.
//

#import "RequestTool.h"
#import "LoginVC.h"
#import <AFNetworking/AFNetworking.h>


//服务器地址
#ifdef DEBUG
//内测
static NSString* const kAPiHost = @"https://baidu.com";
static NSString* const kApiPath = @"api";
#else
//正式
static NSString* const kAPiHost = @"https://baidu.com";
static NSString* const kApiPath = @"api";
#endif
static NSString* const kLoginUrl = @"checkLoginSMSCode";

@implementation Status
@end

@implementation ApiResponseModel
@end

@implementation RequestObject
- (instancetype)initWithRequestURL:(NSString *)url params:(NSDictionary *)dict completedBlock:(ApiCompletedBlock)completed {
    self = [super init];
    if (self) {
        self.requestURL = url;
        self.requestParams = dict;
        self.completedBlock = completed;
    }
    return self;
}
@end

///用户登录失效时候的请求记录，自动登录成功后再次发出之前失败的请求
static NSMutableArray <RequestObject *> *timeoutRequestMArr;

@implementation RequestTool

+ (void)requestApiWithParams:(NSDictionary *)params andRequestUrl:(NSString *)url completedBlock:(ApiCompletedBlock)block {
    // 参数的封装
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //必传参数（服务器定义每次请求毕传参数）
    parameters[@"version"] = App_Version;
    parameters[@"channel"] = @0;
    //追加参数
    [parameters addEntriesFromDictionary:params];
    // url 地址
    NSString *URL = [NSString stringWithFormat:@"%@/%@/%@",kAPiHost, kApiPath, url];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 5;
    
    [manager POST:URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] integerValue] > 0) {
            block ? block(responseObject, YES): nil;
        } else if ([responseObject[@"code"] integerValue] == -1006) {
            // CAUTION:记录保存-1006请求
            timeoutRequestMArr = timeoutRequestMArr? : [NSMutableArray array];
            RequestObject *timeoutRequest = [[RequestObject alloc] initWithRequestURL:url params:params completedBlock:block];
            [timeoutRequestMArr addObject:timeoutRequest];
            [self requestLoginAutomaticallyWithSuccess:^{
                for (RequestObject *request in timeoutRequestMArr) {
                    [self requestApiWithParams:request.requestParams andRequestUrl:request.requestURL completedBlock:request.completedBlock];
                }
                [timeoutRequestMArr removeAllObjects];
            } failure:^{
                [timeoutRequestMArr removeAllObjects];
                // 自动登录失败执行block(比如提示“请登录”,登录成功不提示)
                block ? block(responseObject, NO): nil;
            }];
        } else {
            block ? block(responseObject, NO): nil;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        LQLog(@"Error: %@ ----- API:%@", task.response,url);
        block(nil,NO);
    }];
    [manager invalidateSessionCancelingTasks:NO];
}
#pragma mark - 后台自动登录请求
+ (void)requestLoginAutomaticallyWithSuccess:(void(^)(void))success failure:(void(^)(void))failure {
    
    if (User_Center.ID.length > 0 && User_Center.pass.length > 0) {
        //为了避免重复登录，简单的加锁
        if (!User_Center.isLogining) {
            User_Center.isLogining = YES;  //将要登录状态设为yes
            [self requestApiWithParams:@{@"phone": User_Center.ID,
                                         @"pass": User_Center.pass} andRequestUrl:kLoginUrl completedBlock:^(ApiResponseModel *apiResponseModel, BOOL isSuccess) {
                                             if(apiResponseModel) {  //只能判断dic，不能判断isSuccess，
                                                 switch (apiResponseModel.status.code) {
                                                     case 1:  //登录成功
                                                     {
                                                         [UserCenter resetUserCenterWithDictionary:apiResponseModel.data];
                                                         [UserCenter save];
                                                         success ? success() : nil;
                                                         //                                                               [self pushTokenToServer];
                                                         [self saveCookies];
                                                         
                                                     }
                                                         break;
                                                     default:  //其他情况(服务器会返回-1003，-1006等其他情况，虽然没有登录成功，但是网络请求是成功的)
                                                     {
                                                         failure ? failure() : nil;
                                                         [PageRout_Maneger exitToLoginVC];
                                                     }
                                                         break;
                                                 }
                                             } else {
                                                 failure ? failure() : nil;
                                                 //请求登录接口失败
                                                 [SVProgressHUD showInfoWithStatus:@"网络好像在开小差~"];
                                             }
                                             // CAUTION:禁止多次执行登录请求
                                             // 律师在操作中可能出现一进入APP就调用2~3个网络请求，当这2~3个请求都返回-1006可能导致律师重复调用`checkLoginSMSCode`方法
                                             // 所以以下这句保证5s内不允许再次进入`checkLoginSMSCode`方法
                                             [[RACScheduler mainThreadScheduler] afterDelay:5.0 schedule:^{
                                                 User_Center.isLogining = NO;  //将要登录状态设为NO
                                             }];
                                         }];
        } else {
            // CAUTION:此处超时请求数组中若count为1表示，同时间内的其他请求已经发出(因为被remove掉了)，那么就不用管其他请求，只需请求自己
            // 如果大于1，表示timeoutRequestMArr还没有被remove，所有超时请求都被加入到数组中，登录成功后会循环执行请求！
            if (timeoutRequestMArr.count == 1) {
                for (RequestObject *req in timeoutRequestMArr) {
                    [self requestApiWithParams:req.requestParams andRequestUrl:req.requestURL completedBlock:req.completedBlock];
                }
                [timeoutRequestMArr removeAllObjects];
            }
        }
    } else {  //如果没有用户名或密码，跳转登录界面
        failure ? failure() : nil;
        [UserCenter clearUserCenter];
        [PageRout_Maneger gotoLoginVC];
    }
}
#pragma mark - 保存当前已登录状态cookies
+ (void)saveCookies {
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@",kAPiHost, kApiPath, kLoginUrl];
    NSArray <NSHTTPCookie *> *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:url]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    // CAUTION:此处cookies数组不能直接存进NSUserDefaults(NSUserDefaults不支持NSHTTPCookie类型的存储)
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"cookie"];
}
#pragma mark - 读取上次登录状态cookies
+ (void)loadCookies {
    if ([kUserDefaults objectForKey:@"cookie"]) {
        NSArray <NSHTTPCookie *> *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[kUserDefaults objectForKey:@"cookie"]];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
}
@end
