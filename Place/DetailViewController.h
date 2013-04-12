//
//  DetailViewController.h
//  Place
//
//  Created by Iurii Oliiar on 3/28/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (assign, nonatomic) PlaceMode mode;
@property (retain, nonatomic) NSArray *detailItems;
@property (copy,   nonatomic) NSArray *annotations;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;

- (void)clearMap;

@end
