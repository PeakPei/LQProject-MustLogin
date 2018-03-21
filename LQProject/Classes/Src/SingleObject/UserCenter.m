#import "UserCenter.h"

static UserCenter *_sharedUserCenter;

@implementation UserCenter
+ (instancetype) sharedInstance {
    
    static dispatch_once_t token;
    
    dispatch_once(&token,^{
        
        if ([kUserDefaults objectForKey:@"UserCenter"]) {
            /**
             *  获取保存的用户信息
             */
            NSData *myEncodedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserCenter"];
            _sharedUserCenter = [NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
        }
        if (!_sharedUserCenter) {
            _sharedUserCenter = [[UserCenter alloc] init];
        }
    });
    
    return _sharedUserCenter;
}

+ (BOOL)checkIsLogin {
    return User_Center.ID.length;
}
+ (void)checkIsLoginState:(void(^)(void))success {
    if ([self checkIsLogin]) {
        success?success():nil;
    } else {
        [PageRout_Maneger gotoLoginVC];
    }
}
+ (void)clearUserCenter {
    /**
     *  清除保存到数据
     */
    User_Center.ID = nil;
    User_Center.pass = nil;
    User_Center.uuid = nil;
    User_Center.gender = nil;
    User_Center.nick = nil;
    User_Center.openId = nil;
    User_Center.headurl = nil;
    User_Center.unionLoginType = nil;

    [UserCenter save];
}

+(void)resetUserCenterWithDictionary:(NSDictionary *)dict {
    
    if (dict[@"ID"]) {
        User_Center.ID = dict[@"ID"];
    }
    if (dict[@"pass"]) {
        User_Center.pass = dict[@"pass"];
    }
    if (dict[@"uuid"]) {
        User_Center.uuid = dict[@"uuid"];
    }
    if (dict[@"gender"]) {
        User_Center.gender = dict[@"gender"];
    }
    if (dict[@"nick"]) {
        User_Center.nick = dict[@"nick"];
    }
    if (dict[@"openid"]) {
        User_Center.openId = dict[@"openid"];
    }
    if (dict[@"headurl"]) {
        User_Center.headurl = dict[@"headurl"];
    }
    
    [UserCenter save];
}

+ (void)save{
    
    /**
     *  保存用户信息
     */
    NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:_sharedUserCenter];
    [[NSUserDefaults standardUserDefaults] setObject:archiveData forKey:@"UserCenter"];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.uuid forKey:@"uuid"];
    [aCoder encodeObject:self.pass forKey:@"pass"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.nick forKey:@"nick"];
    [aCoder encodeObject:self.openId forKey:@"openId"];
    [aCoder encodeObject:self.unionLoginType forKey:@"unionLoginType"];
    [aCoder encodeObject:self.headurl forKey:@"headurl"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.ID             = [aDecoder decodeObjectForKey:@"ID"];
        self.pass           = [aDecoder decodeObjectForKey:@"pass"];
        self.uuid           = [aDecoder decodeObjectForKey:@"uuid"];
        self.gender         = [aDecoder decodeObjectForKey:@"gender"];
        self.nick           = [aDecoder decodeObjectForKey:@"nick"];
        self.openId         = [aDecoder decodeObjectForKey:@"openId"];
        self.unionLoginType = [aDecoder decodeObjectForKey:@"unionLoginType"];
        self.headurl        = [aDecoder decodeObjectForKey:@"headurl"];
    }
    return self;
}

@end
