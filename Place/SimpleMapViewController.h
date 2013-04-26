//
//  SimpleMapViewController.h
//  Place
//
//  Created by Iurii Oliiar on 4/25/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKMapView;
@class PlaceEntity;

@interface SimpleMapViewController : UIViewController

@property (retain, nonatomic) IBOutlet MKMapView *mapView;

- (void)addAnnotation:(PlaceEntity *)place;

@end
