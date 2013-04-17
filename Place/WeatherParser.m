//
//  WeatherParser.m
//  Place
//
//  Created by Serhii on 4/8/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "WeatherParser.h"
#import "JSONKit.h"

#define kYahooWeatherXMLKeyLocationTag    @"yweather:location"
#define kYahooWeatherXMLKeyWindTag        @"yweather:wind"
#define kYahooWeatherXMLKeyAtmosphereTag  @"yweather:atmosphere"
#define kYahooWeatherXMLKeyAstronomyTag   @"yweather:astronomy"
#define kYahooWeatherXMLKeyConditionTag   @"yweather:condition"
#define kYahooWeatherXMLKeyConditionDate  @"date"
#define kYahooWeatherXMLKeyForecaseTag    @"yweather:forecast"
#define kYahooWeatherXMLKeyGuidTag        @"guid"
#define kYahooWeatherJSONKeyResultSet     @"ResultSet"
#define kYahooWeatherJSONKeyResults       @"Results"
#define kYahooWeatherJSONKeyWoeid         @"woeid"



@interface WeatherParser ()

@property (nonatomic) int WOEID;
@property (nonatomic) WeatherUnit weatherUnit;

@property (nonatomic, strong) NSDictionary *windDic;
@property (nonatomic, strong) NSDictionary *locationDic;
@property (nonatomic, strong) NSDictionary *atmosphereDic;
@property (nonatomic, strong) NSMutableDictionary *forecaseDataDic;


@property (nonatomic, strong) NSDictionary *astronomyDataDic;
@property (nonatomic, strong) NSDictionary *conditionDataDic;

@property (nonatomic, strong) NSString *guidContent;

@property (nonatomic, strong) NSMutableString *currentNodeContent;

@end

@implementation WeatherParser

@synthesize currentWeather,weatherArray;
@synthesize WOEID,weatherUnit,locationDic,atmosphereDic,forecaseDataDic,astronomyDataDic,conditionDataDic,currentNodeContent;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate weatherUnit:(WeatherUnit)unit{
    
    if ((self = [super init])) {
        
        self.weatherUnit = WeatherUnitCelcius;
        
        NSString *urlStr = [NSString stringWithFormat:@"http://where.yahooapis.com/geocode?location=%f,%f&flags=J&gflags=R&appid=zHgnBS4m",coordinate.latitude,coordinate.longitude];
        NSString *content = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlStr] encoding:NSUTF8StringEncoding error:nil];
        
        NSDictionary *dic = [content objectFromJSONString];
        WOEID = [[[[[dic objectForKey:kYahooWeatherJSONKeyResultSet] objectForKey:kYahooWeatherJSONKeyResults] objectAtIndex:0] objectForKey:kYahooWeatherJSONKeyWoeid] integerValue];
        
        [self parse:[self locationId]];
        
    }
    
    return self;
}

- (NSString *)locationId{
    
    NSString *locationId = nil;
    NSURL *URL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://weather.yahooapis.com/forecastrss?w=%d&u=%@", WOEID, (weatherUnit == WeatherUnitCelcius) ? @"c" : @"f"]];
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    [URL release];
    [xmlParser setDelegate:self];
    if ([xmlParser parse]) {
        NSArray *array = [self.guidContent componentsSeparatedByString:@"_"];
        locationId = [array objectAtIndex:0];
    }
    return locationId;
}

- (void)parse:(NSString *)locationId {
    NSURL *URL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://xml.weather.yahoo.com/forecastrss/%@_c.xml",locationId]];
    NSLog(@"%@",URL);
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    [URL release];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
    if([xmlParser parse]) {
        
        currentWeather = [[Weather alloc] initWeatherWithDic:conditionDataDic];
        
        if (self.locationDic && [self.locationDic objectForKey:@"city"]) {
            currentWeather.cityName = [self.locationDic objectForKey:@"city"];
        }
        if (self.windDic && [self.windDic objectForKey:@"city"]) {
            currentWeather.windChill = [self.locationDic objectForKey:@"chill"];
        }
        if (self.atmosphereDic && [self.atmosphereDic objectForKey:@"city"]) {
            currentWeather.humidity = [self.atmosphereDic objectForKey:@"humidity"];
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"d MMM yyyy"];
        
        NSString *currentDateStr = [formatter stringFromDate:currentWeather.date];
        [formatter release];
        
        if ([forecaseDataDic objectForKey:currentDateStr]) {
            NSDictionary *dic = [forecaseDataDic objectForKey:currentDateStr];
            currentWeather.low = [[dic objectForKey:@"low"] integerValue];
            currentWeather.high = [[dic objectForKey:@"high"] integerValue];
        }
        
        if (self.weatherArray == nil) {
            self.weatherArray = [[[NSMutableArray alloc] init] autorelease];
        }
        
        for (NSString *key in [forecaseDataDic allKeys]) {
            //if ([key isEqualToString:currentDateStr]) {
            //    continue;
            // }
            NSLog(@"keys is %@",key);
            NSLog(@"key %@",[forecaseDataDic objectForKey:key]);
            Weather *weather = [[Weather alloc] initForecastWeatherWithDic:[forecaseDataDic objectForKey:key]];
            [weatherArray addObject:weather];
            [weather release];
            
        }
        
    }
}


#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    if([elementName isEqualToString:kYahooWeatherXMLKeyLocationTag]){
        self.locationDic = attributeDict;
    }
    else if([elementName isEqualToString:kYahooWeatherXMLKeyWindTag]){
        self.windDic = attributeDict;
    }
    else if([elementName isEqualToString:kYahooWeatherXMLKeyAtmosphereTag]){
        self.atmosphereDic = attributeDict;
    }
    else if([elementName isEqualToString:kYahooWeatherXMLKeyConditionTag]){
        self.conditionDataDic = attributeDict;
    }else if([elementName isEqualToString:kYahooWeatherXMLKeyAstronomyTag]){
        
        self.astronomyDataDic = attributeDict;
    }else if([elementName isEqualToString:kYahooWeatherXMLKeyForecaseTag]){
        if (forecaseDataDic == nil) {
            forecaseDataDic = [[NSMutableDictionary alloc] init];
        }
        [forecaseDataDic setObject:attributeDict forKey:[attributeDict objectForKey:kYahooWeatherXMLKeyConditionDate]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName {
    
    if ([elementName isEqualToString:kYahooWeatherXMLKeyGuidTag]) {
        // NSLog(@"currentNodeContent: %@",currentNodeContent);
        self.guidContent = currentNodeContent;
    }
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    currentNodeContent = (NSMutableString *) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
}

@end