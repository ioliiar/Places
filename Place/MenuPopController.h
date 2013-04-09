//
//  MenuPopController.h
//  Place
//
//  Created by Iurii Oliiar on 4/9/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MenuPopController;

@protocol MenuPopControllerDelegate <NSObject>

- (void)menuPopController:(MenuPopController *)menu didChoseItem:(NSInteger)item;

@end

@interface MenuPopController : UITableViewController

@property (nonatomic, assign) id <MenuPopControllerDelegate> delegate;

@end
