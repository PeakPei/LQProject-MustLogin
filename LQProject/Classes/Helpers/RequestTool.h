//
//  Tool.h
//  LawChatForLawyer
//
//  Created by lawchat on 15/5/20.
//  Copyright (c) 2015   jackli. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Status : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString * msg;

@end

@interface ApiResponseModel : NSObject

@property (nonatomic, strong) id data;
@property (nonatomic, strong) Status * status;

@end

@interface RequestObject : NSObject

@property (strong, nonatomic) NSString *requestURL;

@property (strong, nonatomic) NSDictionary *requestParams;

typedef void(^ApiCompletedBlock)(ApiResponseModel *apiResponseModel, BOOL isSuccess);

@property (copy, nonatomic) ApiCompletedBlock completedBlock;

- (instancetype)initWithRequestURL:(NSString *)url params:(NSDictionary *)dict completedBlock:(ApiCompletedBlock)completed;

@end

@interface RequestTool : NSObject

#pragma mark - 网络请求
+ (void)requestApiWithParams:(NSDictionary *)params andRequestUrl:(NSString *)url completedBlock:(ApiCompletedBlock)block;

#pragma mark - 自动登录
+ (void)requestLoginAutomaticallyWithSuccess:(void(^)(void))success failure:(void(^)(void))failure;


@end
