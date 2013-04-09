//
//  Weather.h
//  Place
//
//  Created by Serhii on 4/8/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WeatherUnitCelcius = 0,
    WeatherUnitFahrenheit,
} WeatherUnit;

typedef enum {
    WeatherConditionTornado = 0,
    WeatherConditionTropicalStrom,
    WeatherConditionHurricane,
    WeatherConditionSevereThunderstroms,
    WeatherConditionThunderstorms,
    WeatherConditionMixedRaindAndSnow,
    WeatherConditionMixedRainAndSleet,
    WeatherConditionMixedSnowAndSleet,
    WeatherConditionFexxingDrizzle,
    WeatherConditionDrizzle,
    WeatherConditionFreezingRain,
    WeatherConditionShowers,
    WeatherConditionShowers2,
    WeatherConditionSnowFlurries,
    WeatherConditionLightSnowShowers,
    WeatherConditionBlowingSnow,
    WeatherConditionSnow,
    WeatherConditionHail,
    WeatherConditionSleet,
    WeatherConditionDust,
    WeatherConditionFoggy,
    WeatherConditionHaze,
    WeatherConditionSmoky,
    WeatherConditionBlustery,
    WeatherConditionWindy,
    WeatherConditionCold,
    WeatherConditionCloudy,
    WeatherConditionMostlyCloudyNight,
    WeatherConditionMostlyCloudyDay,
    WeatherConditionPartlyCloudyNight,
    WeatherConditionPartlyCloudyDay,
    WeatherConditionClearNight,
    WeatherConditionSunny,
    WeatherConditionFairNight,
    WeatherConditionFairDay,
    WeatherConditionMixedRainAndHail,
    WeatherConditionHot,
    WeatherConditionIsolatedThunderstorms,
    WeatherConditionScatteredThunderstorms,
    WeatherConditionScatteredThunderstorms2,
    WeatherConditionScatteredShowers,
    WeatherConditionHeavySnow,
    WeatherConditionScatteredSnowShowers,
    WeatherConditionHeavySnow2,
    WeatherConditionPartlyCloudy,
    WeatherConditionThundershowers,
    WeatherConditionSnowShowers,
    WeatherConditionIsolatedThundershowers,
    WeatherConditionNotAvailable,
} WeatherCondition;

@interface Weather : NSObject
{
    WeatherCondition condition;
    int temperature;
    NSString *description;
}


@property (nonatomic, assign) WeatherCondition condition;
@property (nonatomic, assign) WeatherUnit unit;
@property (nonatomic, assign) int temperature;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *description;
@property NSInteger low;
@property NSInteger high;
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *windChill;
@property (nonatomic, strong) NSString *humidity;

- (id)initWeatherWithDic:(NSDictionary *)dic;
- (id)initForecastWeatherWithDic:(NSDictionary *)dic;
- (NSString *)weathImageName;

@end
