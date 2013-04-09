//
//  WeatherManager.h
//  Place
//
//  Created by Serhii on 4/8/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherParser.h"

@interface WeatherManager : NSObject

@property (nonatomic, retain) WeatherParser *yahooWeatherParser;

+ (id) weatherManager;
- (void)fetchWeatherWithCoordinate:(CLLocationCoordinate2D)coordinate weatherUnit:(WeatherUnit)unit;

@end
