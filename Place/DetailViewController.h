//
//  DetailViewController.h
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class DetailViewController;
@class PlaceEntity;
@class RouteEntity;

@protocol DetailViewControllerDelegate <NSObject>

- (void)processPlaceComponent:(NSInteger)component tapCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)processRouteComponent:(NSInteger)component startPoint:(CLLocationCoordinate2D)coordinate;

@end

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (assign, nonatomic) PlaceMode mode;
@property (assign, nonatomic) id <DetailViewControllerDelegate> delegate;
@property (retain, nonatomic) NSArray *detailItems;
@property (copy,   nonatomic) NSArray *annotations;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;


- (void)addAnnotation:(PlaceEntity *)place;
- (void)addRouteOverlay:(RouteEntity *)route;
- (void)clearMap;

@end
