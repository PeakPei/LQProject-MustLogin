//
//  NSString-Verification.h
//  LawChatForLawyer
//
//  Created by Juice on 2016/12/12.
//  Copyright © 2016年 就问律师. All rights reserved.
//  对NSStirng内容格式进行验证

#import <Foundation/Foundation.h>

@interface NSString (Verification)

#pragma mark - 正则匹配手机号
- (BOOL)checkPhoneNumber;

#pragma mark - 正则匹配用户密码6-18位数字和字母组合
- (BOOL)checkPassword;

#pragma mark - 正则匹配用户姓名,20位的中文或英文
- (BOOL)checkUserName;

#pragma mark - 正则匹配用户姓名,12位的中文
- (BOOL)checkUserName_ch;

#pragma mark - 正则匹配用户身份证号
- (BOOL)checkUserIdCard;

#pragma mark - 正则匹配URL
- (BOOL)checkURL;

#pragma mark - 正则匹配2位小数的金额
- (BOOL)checkMoney;

#pragma mark - 正则匹配6位验证码
- (BOOL)checkVerificationCode;

#pragma mark - 检测是否是纯数字
- (BOOL)checkPureDigital;

#pragma mark - 检测字符串中是否含有中文
- (BOOL)checkHasChinese;

@end
