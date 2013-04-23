//
//  IOGhostPickerView.h
//  GhostPicker
//
//  Created by Iurii Oliiar on 12/10/12.
//  Copyright (c) 2012 Iurii Oliiar. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "IOCommon.h"

@class IOGhostPickerView;

@protocol IOGhostPickerDelegate <NSObject>
@optional

- (void)IOGhostPicker:(IOGhostPickerView*)ghostPicker
    didChooseComponent:(NSInteger)component
           inDirection:(NSInteger)direction;

- (void)IOGhostPicker:(IOGhostPickerView *)ghostPicker
 highlightedComponent:(NSInteger)component
          inDirection:(NSInteger)direction
                 view:(UIView*)view;

- (void)IOGhostPicker:(IOGhostPickerView *)ghostPicker cancelledChoosingInDirection:(NSInteger)direction;

@end

@protocol IOGhostPickerDataSource <NSObject>

- (NSUInteger)numberOfDirectionInGhostPicker;
- (NSUInteger)numberOfComponentsInDirection:(NSInteger)direction;

- (UIView*)viewForGhostPickerDirection:(NSInteger)direction;
- (UIView*)viewForComponent:(NSInteger)component inDirection:(NSInteger)direction;

@end

@interface IOGhostPickerView : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<IOGhostPickerDataSource> dataSource;
@property (nonatomic, assign) id<IOGhostPickerDelegate> delegate;
@property (nonatomic, retain) UIView *circleBackgroundView;

- (void)methodForPressRecognizer:(UILongPressGestureRecognizer*)sender;
- (void)displayMenuAnimated:(BOOL)animated;

@end
