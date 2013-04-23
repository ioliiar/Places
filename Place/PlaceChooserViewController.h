//
//  PlaceChooserViewController.h
//  Place
//
//  Created by Iurii Oliiar on 4/22/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PlaceChooserViewController;
@class PlaceEntity;

@protocol PlaceChooserViewControllerDelegate <NSObject>

- (void)placeChooserPickedPlace:(PlaceEntity *)place;

@end

@interface PlaceChooserViewController : UIViewController

@property (assign, nonatomic) id<PlaceChooserViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UITableView *placeTableView;

@end
