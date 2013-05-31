//
//  SimpleMapViewController.m
//  Place
//
//  Created by Iurii Oliiar on 4/25/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "SimpleMapViewController.h"
#import "OptionMapViewController.h"

#import "PlaceEntity.h"
#import "TaggedAnnotation.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "WeaherView.h"
#import "WeatherParser.h"
#import "Weather.h"

@interface SimpleMapViewController ()<OptionMapControllerDelegate, MKMapViewDelegate, WeaherViewDelegate>

@property (nonatomic, retain) TaggedAnnotation *annotation;
@property (nonatomic, retain)  OptionMapViewController *optionVC;
@property (nonatomic, retain) WeaherView *weatherView;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@end

@implementation SimpleMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self.mapView addAnnotation:self.annotation];
    self.mapView.mapType = [[NSUserDefaults standardUserDefaults] integerForKey:kMapType];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_optionVC release];
    [_annotation release];
    [_mapView release];
    [super dealloc];
}
- (void)viewDidUnload {
    self.optionVC = nil;
    self.mapView = nil;
    [super viewDidUnload];
}

- (void)addAnnotation:(PlaceEntity *)place {
    self.annotation = [[[TaggedAnnotation alloc] init] autorelease];
    
    _location.latitude = place.latitude;
    _location.longitude = place.longtitude;
    self.annotation.coordinate = _location;
    self.annotation.title = place.name;
    self.annotation.tag = place.tag;
    
}

- (IBAction)showMapOptions:(UIButton *)sender {
    if (_optionVC == nil) {
        self.optionVC = [[[OptionMapViewController alloc] init] autorelease];
    }
    self.optionVC.mapType = self.mapView.mapType;
    self.optionVC.delegate = self;
    self.optionVC.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController:self.optionVC
                       animated:YES
                     completion:nil];
}

- (void)optionMapVC:(OptionMapViewController *)ovc didSelectmapType:(MKMapType)type {
    self.mapView.mapType = type;
    NSUserDefaults *mapUserPreferences = [NSUserDefaults standardUserDefaults];
    [mapUserPreferences setInteger:type
                            forKey:kMapType];
    [mapUserPreferences synchronize];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
    MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
    if(annotationView)
        return annotationView;
    else
    {
        MKAnnotationView *annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                         reuseIdentifier:AnnotationIdentifier] autorelease];
        
        annotationView.image = [UIImage imageNamed:@"DrawingPin1"];
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:self action:@selector(showWeather:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setTitle:annotation.title forState:UIControlStateNormal];
        annotationView.rightCalloutAccessoryView = rightButton;
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        return annotationView;
    }
    return nil;
}

- (void)showWeather:(id)sender {
    if (self.weatherView) {
        return;
    }

    WeatherParser *yahooWeatherParser = [[[WeatherParser alloc] initWithCoordinate:_location weatherUnit:WeatherUnitCelcius] autorelease];
    NSInteger temp = yahooWeatherParser.currentWeather.temperature;
    WeatherCondition cond = yahooWeatherParser.currentWeather.condition;
    UIImage *weatherImage = [UIImage imageNamed:[NSString stringWithFormat:@"%u.png",cond]];
        
    NSLog(@"temp = %d cond = %d", temp, cond);
    if (temp == 0 && cond == 0) {
        
        self.weatherView = [[[WeaherView alloc] initWithPlaceName:@"No weather was found" weatherIcon:[UIImage imageNamed:@"no_found.png"] tempetatureC:0] autorelease];
        self.weatherView.delegate = self;
        [self.weatherView showOnView:self.mapView];
        
    } else {
        
        if (yahooWeatherParser.currentCity!= NULL && ![yahooWeatherParser.currentCity isKindOfClass:[NSNull class]] && yahooWeatherParser.currentCity!=nil)  {
            
            self.weatherView = [[[WeaherView alloc] initWithPlaceName:yahooWeatherParser.currentCity weatherIcon:weatherImage tempetatureC:temp]autorelease];
            self.weatherView.delegate = self;
            [self.weatherView showOnView:self.mapView];
            
        } else {
            self.weatherView = [[[WeaherView alloc] initWithPlaceName:@"No city was found" weatherIcon:weatherImage tempetatureC:temp] autorelease];
            self.weatherView.delegate = self;
            [self.weatherView showOnView:self.mapView];
        }
    }
}

#pragma mark Weather delegate

- (void) weatherViewDidHide:(WeaherView *)view {
    if (view) {
        self.weatherView = nil;
    }
}


@end
