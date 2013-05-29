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

@interface SimpleMapViewController ()<OptionMapControllerDelegate>

@property (nonatomic, retain) TaggedAnnotation *annotation;
@property (nonatomic, retain)  OptionMapViewController *optionVC;

@end

@implementation SimpleMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapView addAnnotation:self.annotation];
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
    CLLocationCoordinate2D cor;
    cor.latitude = place.latitude;
    cor.longitude = place.longtitude;
    self.annotation.coordinate = cor;
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
}

@end
