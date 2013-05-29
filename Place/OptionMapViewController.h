//
//  OptionMapViewController.h
//  Place
//
//  Created by Iurii Oliiar on 5/29/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKTypes.h>

@class OptionMapViewController;
@protocol OptionMapControllerDelegate <NSObject>

- (void)optionMapVC:(OptionMapViewController *)ovc
   didSelectmapType:(MKMapType)type;

@end

@interface OptionMapViewController : UIViewController

@property (assign, nonatomic) id <OptionMapControllerDelegate> delegate;
@property (assign, nonatomic) MKMapType mapType;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (IBAction)segmentChanged:(UISegmentedControl *)sender;

@end
