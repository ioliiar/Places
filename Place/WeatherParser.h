//
//  WeatherParser.h
//  Place
//
//  Created by Serhii on 4/8/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Weather.h"

@interface WeatherParser :NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) Weather *currentWeather;
@property (nonatomic, strong) NSMutableArray *weatherArray;
@property (nonatomic, copy) NSString *currentCity;
- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate weatherUnit:(WeatherUnit)unit;
- (void)parse:(NSString *)locationId;

@end

