//
//  WeatherManager.m
//  Place
//
//  Created by Serhii on 4/8/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "WeatherManager.h"

@implementation WeatherManager

@synthesize yahooWeatherParser = _yahooWeatherParser;

+ (id)weatherManager {
    
    static WeatherManager *_sharedWeatherManager = nil;
    static dispatch_once_t regionalWeatherManager;
    dispatch_once(&regionalWeatherManager, ^{
        _sharedWeatherManager = [[WeatherManager alloc] init];
    });
    
    return _sharedWeatherManager;
    
}

- (void)fetchWeatherWithCoordinate:(CLLocationCoordinate2D)coordinate weatherUnit:(WeatherUnit)unit{
    
    self.yahooWeatherParser = [[WeatherParser alloc] initWithCoordinate:coordinate weatherUnit:WeatherUnitCelcius];

}

- (void) dealloc {
    [super dealloc];
}
@end
