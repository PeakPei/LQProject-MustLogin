//
//  Common.h
//  lawChat2
//
//  Created by lawchat on 14/12/25.
//  Copyright (c) 2014年 lawchat. All rights reserved.
//

#ifndef UtilsMacro_h
#define UtilsMacro_h

/************* 颜色 ****************/
//rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//获取RGB颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

//应用中常用颜色
#define APPColor_NavigationBar [UIColor whiteColor]
#define APPColor_BackgroudView UIColorFromRGB(0xF8F8F8)
#define APPColor_HudBackground RGBA(34,47,70,0.8)

//按钮色（蓝色）
#define APPColor_Button_Normal UIColorFromRGB(0x3682FF)
#define APPColor_Button_Disable  [UIColor colorWithRed:136.0/255.0 green:178.0/255.0 blue:250.0/255.0 alpha:1.0]
//可操作色 蓝色)
#define APPColor_Blue [UIColor colorWithRed:54.0f/255.0f green:130.0f/255.0f blue:255.0f/255.0f alpha:1.0f]
//成功色 (绿色)
#define APPColor_Green UIColorFromRGB(0x5FD072)
//警示色（红色）
#define APPColor_Red UIColorFromRGB(0xE4593F)
//金额色 (橙色)
#define APPColor_Orange [UIColor colorWithRed:228.0f/255.0f green:89.0f/255.0f blue:63.0f/255.0f alpha:1.0f]

//文本色（不同灰度色）
#define APPColor_333 UIColorFromRGB(0x333333)
#define APPColor_666 UIColorFromRGB(0x666666)
#define APPColor_999 UIColorFromRGB(0x999999)
#define APPColor_BBB UIColorFromRGB(0xBBBBBB)
#define APPColor_DDD UIColorFromRGB(0xDDDDDD)
#define APPColor_Text_b2 [UIColor colorWithRed:178.0f/255.0f green:178.0f/255.0f blue:178.0f/255.0f alpha:1.0f]
#define APPColor_Text_333 [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0          alpha:1.0]
#define APPColor_Text_35 UIColorFromRGB(0x353535)
#define APPColor_Text_5a [UIColor colorWithRed:91.0/255.0 green:91.0/255.0 blue:91.0/255.0           alpha:1.0]
#define APPColor_Text_aaa [UIColor colorWithRed:168.0/255.0 green:168.0/255.0 blue:168.0/255.0       alpha:1.0]
#define APPColor_Text_888 [UIColor colorWithRed:136.0f/255.0f green:136.0f/255.0f blue:136.0f/255.0f alpha:1.0f]
#define APPColor_Text_f9 [UIColor colorWithRed:203.0/255.0 green:203.0/255.0 blue:203.0/255.0        alpha:1.0]
#define APPColor_Text_ccc UIColorFromRGB(0xCCCCCC)
//线条色（线条灰色）
#define APPColor_Line_ddd [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0       alpha:1.0]
#define APPColor_Line_eee UIColorFromRGB(0xEEEEEE)
/************* 颜色 ****************/


/************* 单例宏 ****************/
#define kUserDefaults [NSUserDefaults standardUserDefaults]
#define kNotificationCenter [NSNotificationCenter defaultCenter]
#define kSharedApplication [UIApplication sharedApplication]
#define kAppDelegate (AppDelegate *)[[UIApplication sharedApplication]delegate]
/************* 单例宏 ****************/

// 获取系统时间戳
#define getCurentTime [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]

#endif
