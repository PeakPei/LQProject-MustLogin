//
//  UtilsApi.m
//  LawChatForLawyer
//
//  Created by Juice on 2016/12/12.
//  Copyright © 2016年 就问律师. All rights reserved.
//  一些常用方法的封装

#import "UtilsApi.h"
#import <sys/utsname.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <Contacts/Contacts.h>
#import <CommonCrypto/CommonCrypto.h>
#import "LoginVC.h"
#import "NSDate+Extension.h"

@implementation UtilsApi

#pragma mark - 根据时间戳得到日期字符串
+ (NSString *)dateStringWithTimeStamp:(NSString *)timeStamp formatString:(NSString *)formatStr {
    if (timeStamp.length >= 10) {
        timeStamp = [timeStamp substringToIndex:10];
    } else {
        return @"未知时间";
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatStr];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStamp longLongValue]];
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+ (NSString *)secondTimeStamp:(long long)timeStamp {
    NSString *timeStr = @(timeStamp).stringValue;
    if (timeStr.length > 10) {
        timeStr = [timeStr substringToIndex:10];
    }
    return timeStr;
}

+ (NSString *)timeIntervalBetweenNowAndTimeStamp:(NSString *)timeStamp {
    NSString *result;
    if (timeStamp.length >= 10) {
        timeStamp = [timeStamp substringToIndex:10];
        NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:timeStamp.integerValue];
        //八小时时区
        NSInteger interval = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:timeDate];
        NSDate *mydate = [timeDate dateByAddingTimeInterval:interval];
        NSDate *nowDate = [[NSDate date] dateByAddingTimeInterval:interval];
        //两个时间间隔
        NSTimeInterval timeInterval = [mydate timeIntervalSinceDate:nowDate];
        timeInterval = -timeInterval;
        int temp;
        if (timeInterval < 60) {
            result = [NSString stringWithFormat:@"刚刚"];
        }
        else if((temp = timeInterval / 60) < 60){
            result = [NSString stringWithFormat:@"%zd分钟前",temp];
        }
        else if((temp = temp / 60) < 24){
            result = [NSString stringWithFormat:@"%zd小时前",temp];
        }
        else if((temp = temp/24) <30){
            result = [NSString stringWithFormat:@"%zd天前",temp];
        }
        else if((temp = temp/30) <12){
            result = [NSString stringWithFormat:@"%zd月前",temp];
        }
        else{
            temp   = temp/12;
            result = [NSString stringWithFormat:@"%zd年前",temp];
        }
    }
    else {
        result = @"未知时间";
    }
    return  result;
}
+(NSDate *)dateWithTimeStamp:(NSString *)stampTime{
    long long time = stampTime.longLongValue;
    if (stampTime.length >= 10) {
        //毫秒
        time = time/1000;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: time];
    return date;
}
+(NSString *)getNowTimeTimestamp{
    
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒

    return [NSString stringWithFormat:@"%.0f",time];
    
}
//是否为同一天
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    return [comp1 day] == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}
+ (NSString *)wechat_timeIntervalBetweenNowAndTimeStamp:(NSString *)timeStamp {
    NSString *result;
    if (timeStamp.length >= 10) {
        timeStamp = [timeStamp substringToIndex:10];
        NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:timeStamp.integerValue];
        //八小时时区
        NSInteger interval = [[NSTimeZone systemTimeZone] secondsFromGMTForDate:timeDate];
        NSDate *mydate = [timeDate dateByAddingTimeInterval:interval];
        NSDate *nowDate = [[NSDate date] dateByAddingTimeInterval:interval];
        //两个时间间隔
        NSTimeInterval timeInterval = [mydate timeIntervalSinceDate:nowDate];
        timeInterval = -timeInterval;
        //格式化显示
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStamp longLongValue]];
        if ([date isToday]) {
            formatter.dateFormat = @"HH:mm";
        } else if ([date isYesterday]) {
            formatter.dateFormat = @"昨天 HH:mm";
        } else if ([date isSameWeek]) {
            formatter.dateFormat = @"EEEE";
        } else {
            formatter.dateFormat = @"yyyy/MM/dd";
        }
        result = [formatter stringFromDate:date];
    } else {
        result = @"未知时间";
    }
    return  result;
}

#pragma mark - 显示警示框（无标题，一个按钮）
+ (QMUIAlertController*)showAlertMessage:(NSString*)message okBlock:(void(^)())okBlock {
    return [self showAlertMessage:message okText:@"知道了" okBlock:okBlock];
}
#pragma mark - 显示警示框（无标题，一个按钮）
+ (QMUIAlertController*)showAlertMessage:(NSString*)message okText:(NSString *)okText okBlock:(void(^)())okBlock {
    // 弹窗
    QMUIAlertController *alertController = [[QMUIAlertController alloc] initWithTitle:nil message:message preferredStyle:QMUIAlertControllerStyleAlert];
    alertController.alertContentMaximumWidth = 285;
    alertController.alertButtonBackgroundColor = UIColorWhite;
    alertController.alertContentCornerRadius = 2;
    alertController.alertButtonHeight = 50;
    alertController.alertHeaderInsets = UIEdgeInsetsMake(40, 20, 25, 20);
    alertController.alertHeaderBackgroundColor = UIColorWhite;
    alertController.alertSeperatorColor = APPColor_Line_ddd;
    
    NSMutableDictionary *messageAttributs = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertMessageAttributes];
    messageAttributs[NSForegroundColorAttributeName] = UIColorBlack;
    messageAttributs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.minimumLineHeight = 22;
    messageAttributs[NSParagraphStyleAttributeName] = ps;
    alertController.alertMessageAttributes = messageAttributs;
    
    NSMutableDictionary *cancelButtonAttributes = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertCancelButtonAttributes];
    cancelButtonAttributes[NSForegroundColorAttributeName] = UIColorMakeWithHex(@"#3682ff");
    alertController.alertCancelButtonAttributes = cancelButtonAttributes;
    
    // 底部按钮
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:okText style:QMUIAlertActionStyleCancel handler:^(QMUIAlertAction *action) {
        okBlock?okBlock():nil;
    }];
    [alertController addAction:action1];
    [alertController showWithAnimated:YES];
    
    return alertController;
}

#pragma mark - 显示警示框（有标题，一个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString*)message okBlock:(void(^)())okBlock {
    return [self showAlertTitle:title message:message okText:@"知道了" okBlock:okBlock];
}
#pragma mark - 显示警示框（有标题，一个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString*)message okText:(NSString*)okText okBlock:(void (^) ())okBlock {
    // 弹窗
    QMUIAlertController *alertController = [[QMUIAlertController alloc] initWithTitle:title message:message preferredStyle:QMUIAlertControllerStyleAlert];
    alertController.alertContentMaximumWidth = 285;
    alertController.alertButtonBackgroundColor = UIColorWhite;
    alertController.alertContentCornerRadius = 2;
    alertController.alertButtonHeight = 50;
    alertController.alertHeaderInsets = UIEdgeInsetsMake(30, 25, 20, 25);
    alertController.alertTitleMessageSpacing = 13;
    alertController.alertHeaderBackgroundColor = UIColorWhite;
    alertController.alertSeperatorColor = APPColor_Line_ddd;
    
    NSMutableDictionary *titleAttributs = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertTitleAttributes];
    titleAttributs[NSForegroundColorAttributeName] = UIColorBlack;
    titleAttributs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
    alertController.alertTitleAttributes = titleAttributs;
    
    NSMutableDictionary *messageAttributs = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertMessageAttributes];
    messageAttributs[NSForegroundColorAttributeName] = APPColor_999;
    messageAttributs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.minimumLineHeight = 22;
    messageAttributs[NSParagraphStyleAttributeName] = ps;
    alertController.alertMessageAttributes = messageAttributs;
    
    NSMutableDictionary *buttonAttributes = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertButtonAttributes];
    buttonAttributes[NSForegroundColorAttributeName] = UIColorMakeWithHex(@"#3682ff");
    alertController.alertButtonAttributes = buttonAttributes;
    
    NSMutableDictionary *cancelButtonAttributes = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertCancelButtonAttributes];
    cancelButtonAttributes[NSForegroundColorAttributeName] = UIColorMakeWithHex(@"#3682ff");
    alertController.alertCancelButtonAttributes = cancelButtonAttributes;
    
    // 底部按钮
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:okText style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
        okBlock?okBlock():nil;
    }];
    [alertController addAction:action1];
    [alertController showWithAnimated:YES];
    
    return alertController;
}
#pragma mark - 显示警示框（有标题，两个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString *)message cancelBlock:(void (^) ())cancelBlock okBlock:(void (^) ())okBlock {
    return [self showAlertTitle:title message:message cancelText:@"取消" okText:@"确定" okImage:nil  cancelBlock:cancelBlock okBlock:okBlock];
}
#pragma mark - 显示警示框（有标题，两个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString *)message cancelText:(NSString*)cancelText okText:(NSString*)okText cancelBlock:(void (^) ())cancelBlock okBlock:(void (^) ())okBlock {
    return [self showAlertTitle:title message:message cancelText:cancelText okText:okText okImage:nil cancelBlock:cancelBlock okBlock:okBlock];
}
#pragma mark - 显示警示框（有标题，两个按钮）
+ (QMUIAlertController*)showAlertTitle:(NSString *)title message:(NSString *)message cancelText:(NSString*)cancelText okText:(NSString*)okText okImage:(UIImage*)okImage cancelBlock:(void (^) ())cancelBlock okBlock:(void (^) ())okBlock {
    // 弹窗
    QMUIAlertController *alertController = [[QMUIAlertController alloc] initWithTitle:title message:message preferredStyle:QMUIAlertControllerStyleAlert];
    alertController.alertContentMaximumWidth = 285;
    alertController.alertButtonBackgroundColor = UIColorWhite;
    alertController.alertContentCornerRadius = 2;
    alertController.alertButtonHeight = 50;
    alertController.alertHeaderInsets = UIEdgeInsetsMake(30, 25, 20, 25);
    alertController.alertTitleMessageSpacing = 13;
    alertController.alertHeaderBackgroundColor = UIColorWhite;
    alertController.alertSeperatorColor = APPColor_Line_ddd;
    
    NSMutableDictionary *titleAttributs = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertTitleAttributes];
    titleAttributs[NSForegroundColorAttributeName] = UIColorBlack;
    titleAttributs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
    alertController.alertTitleAttributes = titleAttributs;
    
    NSMutableDictionary *messageAttributs = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertMessageAttributes];
    messageAttributs[NSForegroundColorAttributeName] = APPColor_999;
    messageAttributs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
    ps.minimumLineHeight = 22;
    messageAttributs[NSParagraphStyleAttributeName] = ps;
    alertController.alertMessageAttributes = messageAttributs;
    
    NSMutableDictionary *buttonAttributes = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertButtonAttributes];
    buttonAttributes[NSForegroundColorAttributeName] = UIColorMakeWithHex(@"#3682ff");
    alertController.alertButtonAttributes = buttonAttributes;
    
    NSMutableDictionary *cancelButtonAttributes = [[NSMutableDictionary alloc] initWithDictionary:alertController.alertCancelButtonAttributes];
    cancelButtonAttributes[NSForegroundColorAttributeName] = UIColorBlack;
    cancelButtonAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:17];
    alertController.alertCancelButtonAttributes = cancelButtonAttributes;
    
    // 底部按钮
    QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:cancelText style:QMUIAlertActionStyleCancel handler:^(QMUIAlertAction *action) {
        cancelBlock?cancelBlock():nil;
    }];
    QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:okText style:QMUIAlertActionStyleDefault handler:^(QMUIAlertAction *action) {
        okBlock?okBlock():nil;
    }];
    if (okImage) {
        [action2.button setImage:okImage forState:UIControlStateNormal];
        action2.button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    }
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController showWithAnimated:YES];
    
    return alertController;
}

+ (void)showActionSheetWithCamera:(void(^)())cameraBlock album:(void(^)())albumBlock {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请按照示例图上传执业证清晰照，请勿旋转方向或打码" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [SVProgressHUD showInfoWithStatus:@"您的设备不支持相机"];
        } else {
            cameraBlock ? cameraBlock() : nil;
        }
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        albumBlock ? albumBlock() : nil;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cameraAction];
    [alertController addAction:albumAction];
    [alertController addAction:cancelAction];

    [PageRout_Maneger.currentNaviVC presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 通过Storyboard跳转vc（不传参数）
+ (void)pushViewControllerFrom:(UIViewController *)viewController toViewController:(Class)viewControllerClass inStoryboard:(NSString *)storyboardName andBundle:(NSBundle *)bundle andAnimated:(BOOL)animated {
    UIStoryboard *SB = [UIStoryboard storyboardWithName:storyboardName bundle:bundle];
    UIViewController *VC = [SB instantiateViewControllerWithIdentifier:NSStringFromClass(viewControllerClass)];
    [viewController.navigationController pushViewController:VC animated:animated];
}

#pragma mark - 获取到当前界面处于的viewController
+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    
    UIWindow * window = [kSharedApplication keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [kSharedApplication windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

#pragma mark - 得到具体的设备型号
+ (NSString *)getConcreteDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}
+ (NSString*)getTheCorrectNum:(NSString*)tempString
{
    //先判断第一位是不是 . ,是 . 补0
    if ([tempString hasPrefix:@"."]) {
        tempString = [NSString stringWithFormat:@"0%@",tempString];
    }
    //计算截取的长度
    NSUInteger endLength = tempString.length;
    //判断字符串是否包含 .
    if ([tempString containsString:@"."]) {
        //取得 . 的位置
        NSRange pointRange = [tempString rangeOfString:@"."];
        LQLog(@"%lu",(unsigned long)pointRange.location);
        //判断 . 后面有几位
        NSUInteger f = tempString.length - 1 - pointRange.location;
        //如果大于2位就截取字符串保留两位,如果小于两位,直接截取
        if (f > 2) {
            endLength = pointRange.location + 2;
        }
    }
    //先将tempString转换成char型数组
    NSUInteger start = 0;
    const char *tempChar = [tempString UTF8String];
    //遍历,去除取得第一位不是0的位置
    for (int i = 0; i < tempString.length; i++) {
        if (tempChar[i] == '0') {
            start++;
        }
        else
        {
            break;
        }
    }
    //如果第一个字母为 . start后退一位
    if (tempChar[start] == '.') {
        start--;
    }
    //根据最终的开始位置,计算长度,并截取
    NSRange range = {start,endLength-start};
    tempString = [tempString substringWithRange:range];
    
    return tempString;
}
#pragma mark - push网页
+ (AXWebViewController *)gotoWebWithUrl:(NSString*)url inNavigationVC:(UINavigationController*)navigationVC{
    
    AXWebViewController *webVC = [[AXWebViewController alloc] initWithAddress:url];
    webVC.showsToolBar = NO;
    if (AX_WEB_VIEW_CONTROLLER_iOS9_0_AVAILABLE()) {
        webVC.webView.allowsLinkPreview = YES;
    }
    if (navigationVC) {
        [navigationVC pushViewController:webVC animated:YES];
    } else {
        [PageRout_Maneger.currentNaviVC pushViewController:webVC animated:YES];
    }
    return webVC;
}
+ (AXWebViewController *)gotoWebWithUrl:(NSString*)url inNavigationVC:(UINavigationController*)navigationVC navTitle:(NSString *)title{
    AXWebViewController *webVC = [[AXWebViewController alloc] initWithAddress:url];
    webVC.title = title;
    webVC.showsToolBar = NO;
    if (AX_WEB_VIEW_CONTROLLER_iOS9_0_AVAILABLE()) {
        webVC.webView.allowsLinkPreview = YES;
    }
    if (navigationVC) {
        [navigationVC pushViewController:webVC animated:YES];
    } else {
        [PageRout_Maneger.currentNaviVC pushViewController:webVC animated:YES];
    }
    return webVC;
}

/**
 *  打电话
 *
 *  @param phoneNumber 电话号码
 */
+ (void) callPhoneWithPhoneNumber:(NSString *) phoneNumber{
    phoneNumber = phoneNumber.length == 0 ? @"4006012708" : phoneNumber;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [[UIApplication sharedApplication] openURL:url options:@{}
                                 completionHandler:nil];
    } else {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}
+ (void)showCallPhoneAlertWithPhone:(NSString*)phone {
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 10.2) {
        [self callPhoneWithPhoneNumber:phone];
    } else {
        UIImage *img = [[UIImage imageNamed:@"呼叫"] qmui_imageResizedInLimitedSize:CGSizeMake(22, 22) contentMode:UIViewContentModeScaleToFill];
        img = [img qmui_imageWithTintColor:UIColorMakeWithHex(@"3682ff")];
        [self showAlertTitle:@"拨打电话" message:phone cancelText:@"取消" okText:@"呼叫" okImage:img cancelBlock:nil okBlock:^{
            [self callPhoneWithPhoneNumber:phone];
        }];
    }
}
#pragma mark - 过滤字符串
+ (NSString *)filterSensitiveWords:(NSString*)string {
    string = [string stringByReplacingOccurrencesOfString:@"微信" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"微 信" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"weixin" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"威信" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"威 信" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"电话" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"电 话" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"殿话" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"店话" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"tel" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"dianhua" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"dian hua" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"免费" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"手机" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"手 机" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, string.length)];
    string = [string stringByReplacingOccurrencesOfString:@"\\d{7,11}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, string.length)];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return string;
}
+ (NSString *)formatMoneyFloat:(double)num
{
    if (fmodf(num, 1)==0) {
        return [NSString stringWithFormat:@"%.0f",num];
    } else if (fmodf(num*10, 1)==0) {//如果有一位小数点
        return [NSString stringWithFormat:@"%.1f",num];
    } else {//如果有两位小数点
        return [NSString stringWithFormat:@"%.2f",num];
    }
}
+ (NSString *)deviceIPAdress {
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    return address;
}
+ (NSString *)md5Encryption:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    
    return result;
}

/**
 *  MD5加密后，使用BASE64方式编码成字符串
 */
+(NSString *) md5: (NSData *) data
{
    NSString * tempStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5([tempStr UTF8String], (uint)strlen([tempStr UTF8String]), digist);
    NSData * md5data = [[NSData alloc] initWithBytes:digist length:sizeof(digist)];
    NSString * result = [md5data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return result;
}

@end
