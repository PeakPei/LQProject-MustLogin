//
//  NSDate+Extension.m
//  LawChatForLawyer
//
//  Created by Juice on 2017/12/28.
//  Copyright © 2017年 就问律师. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

//是否为今天
- (BOOL)isToday
{
    //now: 2015-09-05 11:23:00
    //self 调用这个方法的对象本身
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear ;
    
    //1.获得当前时间的 年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //2.获得self
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}

//是否为昨天
- (BOOL)isYesterday
{
    //2014-05-01
    NSDate *nowDate = [[NSDate date] dateWithYMD];
    
    //2014-04-30
    NSDate *selfDate = [self dateWithYMD];
    
    //获得nowDate和selfDate的差距
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    
    return cmps.day == 1;
}

//格式化
- (NSDate *)dateWithYMD
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

//是否在同一周
- (BOOL)isSameWeek
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear ;
    
    //1.获得当前时间的 年月日
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[NSDate date]];
    
    //2.获得self
    NSDateComponents *selfCmps = [calendar components:unit fromDate:self];
    
    return (selfCmps.year == nowCmps.year) && (selfCmps.month == nowCmps.month) && (selfCmps.day == nowCmps.day);
}

@end
