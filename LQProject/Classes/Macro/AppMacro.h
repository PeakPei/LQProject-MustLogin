//
//  ServerDefine.h
//  PublicLawyerChat
//
//  Created by lawchat on 16/5/6.
//  Copyright © 2016年 李庆. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h


#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define AppStore_URL @"http://itunes.apple.com/lookup?id=xxx"

//  自定义更详细的Log
#ifdef DEBUG
#define LQLog(fmt, ...) NSLog((@"%s [Line %d] 🐔🐔🐔:" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define LQLog(...)
#endif
// 系统版本号
#define CurrentSystemVersion [[UIDevice currentDevice] systemVersion]
// 应用版本号
#define App_Version [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#endif /* ServerDefine_h */
