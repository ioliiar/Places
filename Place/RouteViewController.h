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
- (IBAction)saveAction:(UIBarButtonItem *)sender;
- (IBAction)doneAction:(UIBarButtonItem *)sender;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *doneBtn;

@end
