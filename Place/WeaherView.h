//
//  WeaherView.h
//  Place
//
//  Created by Serhii on 5/22/13.
//  Copyright (c) 2013 Serhii. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WeaherView;

@protocol WeaherViewDelegate <NSObject>
@optional
- (void)weatherViewDidHide:(WeaherView *)view;
@end


@interface WeaherView : UIView

@property (nonatomic, assign) id <WeaherViewDelegate> delegate;
@property (nonatomic) BOOL isVisible;
- (id) initWithPlaceName:(NSString*)aName weatherIcon:(UIImage*) aIcon tempetatureC:(NSInteger) temp;
- (void)showOnView:(UIView *)superview;
- (void)hide;

@end
