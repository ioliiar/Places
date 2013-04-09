//
//  RouteViewController.h
//  Place
//
//  Created by Iurii Oliiar on 4/1/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RouteEntity;

@interface RouteViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) RouteEntity *route; // route entities
@property (retain, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)saveAction:(UIButton *)sender;
- (IBAction)doneAction:(UIButton *)sender;

@end
