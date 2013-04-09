//
//  Weather.m
//  Place
//
//  Created by Serhii on 4/8/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "Weather.h"

@implementation Weather

@synthesize condition,temperature, date,description,low,high,cityName,windChill,humidity;

- (id)initWeatherWithDic:(NSDictionary *)dic{
    
    if ((self = [super init])) {
        
        self.temperature = [[dic objectForKey:@"temp"] integerValue];
        self.condition = [[dic objectForKey:@"code"] integerValue];
        self.date = [self getDateFromStr:[dic objectForKey:@"date"]];
        self.description = [dic objectForKey:@"text"];
        
    }
    
    return self;
}


- (id)initForecastWeatherWithDic:(NSDictionary *)dic{
    
    if ((self = [super init])) {
        
        self.condition = [[dic objectForKey:@"code"] integerValue];
        self.date = [self getForecastDateFromStr:[dic objectForKey:@"date"]];
        self.description = [dic objectForKey:@"text"];
        self.low = [[dic objectForKey:@"low"] integerValue];
        self.high = [[dic objectForKey:@"high"] integerValue];
        
    }
    
    return self;
}

- (NSString *)weathImageName{
    
    NSString *weathImageName = [NSString stringWithFormat:@"%d",condition];
    
    return weathImageName;
    
}

- (NSDate *)getDateFromStr:(NSString *)dateStr{
    
    NSDate *resultDate = nil;
    
    NSArray *array = [dateStr componentsSeparatedByString:@" "];
    dateStr = [dateStr stringByReplacingOccurrencesOfString:[array lastObject] withString:@""];
    dateStr = [dateStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSLog(@"dateStr: %@",dateStr);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"EEE, dd MMM yyyy h:mm a"];
    
    resultDate = [formatter dateFromString:dateStr];
    
    return resultDate;
}


- (NSDate *)getForecastDateFromStr:(NSString *)dateStr{
    
    NSDate *resultDate = nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"d MMM yyyy"];
    
    resultDate = [formatter dateFromString:dateStr];
    
    return resultDate;
}

@end