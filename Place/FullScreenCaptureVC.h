//
//  FullScreenCaptureVC.h
//  Place
//
//  Created by Iurii Oliiar on 4/25/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FullScreenCaptureVC;

@protocol FullScreenVCDelegate <NSObject>

- (void)fullScreenVCFinishedPickingImage:(UIImage *)image;
- (void)fullScreenVCCancelledPicking;

@end

@interface FullScreenCaptureVC : UIViewController

@property (retain, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, assign) id<FullScreenVCDelegate> delegate;
- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)capture:(UIBarButtonItem *)sender;
@end
