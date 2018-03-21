//
//  UtilsApi.h
//  LawChatForLawyer
//
//  Created by Juice on 2016/12/12.
//  Copyright © 2016年 就问律师. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AXWebViewController/AXWebViewController-umbrella.h>

@class QMUIAlertController;

@interface UtilsApi : NSObject

#pragma mark - 根据时间戳得到日期字符串
+ (NSString *)dateStringWithTimeStamp:(NSString *)timeStamp formatString:(NSString *)formatStr;

/**
 得到以秒为单位的时间戳(10位，单位为秒)，网络返回的时间戳是13位（单位为毫秒）的
 */
+ (NSString *)secondTimeStamp:(long long)timeStamp;

/**
 返回指定时间与当前时间的间隔
 */
+ (NSString *)timeIntervalBetweenNowAndTimeStamp:(NSString *)timeStamp;

/**
 消息列表时间显示规则(仿微信)
 */
+ (NSString *)wechat_timeIntervalBetweenNowAndTimeStamp:(NSString *)timeStamp;
/**
 时间戳转date
 */
+(NSDate *)dateWithTimeStamp:(NSString *)stampTime;
//获取当前时间戳
+(NSString *)getNowTimeTimestamp;

//是否为同一天
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2;

#pragma mark - 显示警示框（无标题，一个按钮）
+ (QMUIAlertController*)showAlertMessage:(NSString*)message okBlock:(void(^)())okBlock;
#pragma mark - 显示警示框（无标题，一个按钮）
+ (QMUIAlertController*)showAlertMessage:(NSString*)message okText:(NSString *)okText okBlock:(void(^)())okBlock;
#pragma mark - 显示警示框（有标题，一个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString*)message okBlock:(void(^)())okBlock;
#pragma mark - 显示警示框（有标题，一个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString*)message okText:(NSString*)okText okBlock:(void (^) ())okBlock;
#pragma mark - 显示警示框（有标题，两个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString *)message cancelBlock:(void (^) ())cancelBlock okBlock:(void (^) ())okBlock;
#pragma mark - 显示警示框（有标题，两个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString *)message cancelText:(NSString*)cancelText okText:(NSString*)okText cancelBlock:(void (^) ())cancelBlock okBlock:(void (^) ())okBlock;
#pragma mark - 显示警示框（有标题，两个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString *)message cancelText:(NSString*)cancelText okText:(NSString*)okText okImage:(UIImage*)okImage cancelBlock:(void (^) ())cancelBlock okBlock:(void (^) ())okBlock;

/**
 拍照、从图片选择
 */
+ (void)showActionSheetWithCamera:(void(^)())cameraBlock album:(void(^)())albumBlock;

#pragma mark - 通过Storyboard跳转vc（不传参数）
+ (void)pushViewControllerFrom:(UIViewController *)viewController toViewController:(Class)viewControllerClass inStoryboard:(NSString *)storyboardName andBundle:(NSBundle *)bundle andAnimated:(BOOL)animated;

#pragma mark - 获取到当前界面处于的viewController
+ (UIViewController *)getCurrentVC;

#pragma mark - 得到具体的设备型号
+ (NSString *)getConcreteDeviceModel;

#pragma mark - 格式化金额输入字符
+ (NSString*)getTheCorrectNum:(NSString*)tempString;

+ (AXWebViewController *)gotoWebWithUrl:(NSString*)url inNavigationVC:(UINavigationController*)navigationVC;
+ (AXWebViewController *)gotoWebWithUrl:(NSString*)url inNavigationVC:(UINavigationController*)navigationVC navTitle:(NSString *)title;

#pragma mark - 拨打电话
+ (void) callPhoneWithPhoneNumber:(NSString *) phoneNumber;
#pragma mark - 显示拨打电话提示
+ (void)showCallPhoneAlertWithPhone:(NSString*)phone;

#pragma mark - 过滤字符串
+ (NSString *)filterSensitiveWords:(NSString*)string;

#pragma mark - 金额小数精确位数处理
+ (NSString *)formatMoneyFloat:(double)num;

#pragma mark - 获得IP地址
+ (NSString *)deviceIPAdress;

#pragma mark - md5运算
+ (NSString *)md5Encryption:(NSString *)string;
#pragma mark - md5运算(NSData)
+ (NSString *) md5: (NSData *) data;


@end

