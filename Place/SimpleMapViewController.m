//
//  SimpleMapViewController.m
//  Place
//
//  Created by Iurii Oliiar on 4/25/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "SimpleMapViewController.h"
#import "PlaceEntity.h"
#import "TaggedAnnotation.h"
#import <CoreLocation/CoreLocation.h>

#import <MapKit/MapKit.h>

@interface SimpleMapViewController ()

@property (nonatomic, retain) TaggedAnnotation *annotation;

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
    [_annotation release];
    [_mapView release];
    [super dealloc];
}
- (void)viewDidUnload {
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

@end
