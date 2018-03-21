#import <Foundation/Foundation.h>

#define User_Center [UserCenter sharedInstance]

@interface UserCenter : NSObject<NSCoding>

//用户ID(手机号)
@property (nonatomic, strong) NSString *ID;
//用户通行证(手机号和密码经MD5加密后的字符串)
@property (nonatomic, strong) NSString *pass;
//用户登录凭证
@property (nonatomic, strong) NSString *uuid;

//性别
@property (nonatomic, strong) NSNumber *gender;

//昵称
@property (nonatomic, strong) NSString *nick;

//联合登录三方id
@property (nonatomic , strong) NSString *openId;

//头像
@property (nonatomic , strong) NSString *headurl;


//联合登录类型（QQ联合登录=1，微信联合登录=2）
@property (nonatomic , strong) NSNumber *unionLoginType;

@property (nonatomic) BOOL isLogining;  //防止多次请求登录
//获得单列
+ (instancetype)sharedInstance;
//是否登录
+ (BOOL)checkIsLogin;
//清除用户中心数据
+ (void)clearUserCenter;
//设置用户中心数据
+(void)resetUserCenterWithDictionary:(NSDictionary *)dict;
//存档
+ (void)save;
@end
