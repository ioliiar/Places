//
//  IOGhostPickerView.m
//  GhostPicker
//
//  Created by Iurii Oliiar on 12/10/12.
//  Copyright (c) 2012 Iurii Oliiar. All rights reserved.
//

#import "IOGhostPickerView.h"

@interface IOGhostPickerView () {    
    NSInteger directionNumber;
    NSInteger compomentNumber;
    NSInteger lastComponentNumber;
    CGPoint center;
    CGFloat imageSize;
}

@property (nonatomic, copy) NSArray *menuItems;
@property (nonatomic, copy) NSArray *submenuItems;
@property (nonatomic, retain) UIImageView *circle;
@property (nonatomic, retain) UIView *defaultCenterView;

@end

@implementation IOGhostPickerView 

@synthesize menuItems;
@synthesize submenuItems;
@synthesize circle;
@synthesize delegate;
@synthesize dataSource;
@synthesize circleBackgroundView;
@synthesize defaultCenterView;

- (void)setCircleBackgroundView:(UIView *)value {
    
    if (circleBackgroundView != value) {
        if (circleBackgroundView != nil) {
            [circleBackgroundView removeFromSuperview];
        }
        [circleBackgroundView release];
        circleBackgroundView =  [value retain];
        self.circleBackgroundView.frame = CGRectMake(center.x - kGhostPickerRadius, center.y - kGhostPickerRadius,
                                                     2*kGhostPickerRadius, 2*kGhostPickerRadius);
        [self addSubview:circleBackgroundView];
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        directionNumber = -1;
        compomentNumber = -1;
        lastComponentNumber = -1;
        imageSize = kGhostPickerImageSize;
        center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
    return self;
}

- (void)loadMenuIfNeeded {
    if (self.menuItems == nil) {
        int count = [dataSource numberOfDirectionInGhostPicker];       
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i < count; i++) {
            UIView *v = [dataSource viewForGhostPickerDirection:i];
            [self addSubview:v];
            [array addObject:v];
        }
        
        self.menuItems = array;
    }
}

- (void)loadSubmenuItemsForDirection:(NSInteger)direction {
    int count = [dataSource numberOfComponentsInDirection:direction];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        UIView *v = [dataSource viewForComponent:i inDirection:direction];
        [self addSubview:v];
        [array addObject:v];
    }
    self.submenuItems = array;
}

- (void)moveSubMenusToFrame:(CGRect)rect alpha:(CGFloat)alpha {
    for (UIView *v in self.submenuItems) {
        v.frame = rect;
        v.alpha = alpha;
    }
}

- (void)layoutSubMenuItemsRadialForDirection:(NSInteger)direction alpha:(CGFloat)alpha {
    int count = [self.menuItems count];
    int itemsCount = [self.submenuItems count];
    double betta = M_PI / 3;
    double q = betta * (itemsCount - 1);
    double from = 2 * M_PI / count * direction - q / 2;
    double to = 2 * M_PI / count * direction + q / 2;
    
    CGRect rect = self.bounds;
    CGFloat xCenter = rect.size.width / 2;
    CGFloat yCenter = rect.size.height / 2;
    rect.size = CGSizeMake(kGhostPickerImageSize, kGhostPickerImageSize);
    
    NSInteger index = 0;
    for (double i = from; i < to + betta / 2; i += betta) {
        rect.origin.x = (kGhostPickerRadius + 15) * cos(i);
        rect.origin.y = -(kGhostPickerRadius + 15) * sin(i);
        rect.origin.x += xCenter - kGhostPickerImageSize / 2;
        rect.origin.y += yCenter - kGhostPickerImageSize / 2;
        
        UIView *v = [self.submenuItems objectAtIndex:index++];
        v.frame = rect;
        v.alpha = alpha;
    }
}

- (void)centerMenuItemsAndChangeAlpha:(CGFloat)alpha {
    CGRect rect = self.bounds;
    rect.origin = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    rect.origin.x -= kGhostPickerImageSize / 2;
    rect.origin.y -= kGhostPickerImageSize / 2;
    rect.size = CGSizeMake(kGhostPickerImageSize, kGhostPickerImageSize);
        for (UIView *v in self.menuItems) {
        v.frame = rect;
        v.alpha = alpha;
    }
}

- (void)layoutMenuItemsRadial {
    CGRect rect = self.bounds;
    CGFloat xCenter = rect.size.width / 2;
    CGFloat yCenter = rect.size.height / 2;
    rect.size = CGSizeMake(kGhostPickerImageSize, kGhostPickerImageSize);
       
    int count = [self.menuItems count];
    for (int i = 0; i < count; i++) {
        double r = 2 * M_PI / count * i;
        rect.origin.x = (kGhostPickerRadius + 15) * cos(r);
        rect.origin.y = -(kGhostPickerRadius + 15) * sin(r);
        rect.origin.x += xCenter - kGhostPickerImageSize / 2;
        rect.origin.y += yCenter - kGhostPickerImageSize / 2;
        
        UIView *v = [self.menuItems objectAtIndex:i];
        v.frame = rect;
    }
}

- (void)displayCircle {
    circle = [[UIImageView alloc] initWithFrame:
              CGRectMake(center.x - 0.5 * kGhostPickerRadius , center.y - 0.5 * kGhostPickerRadius,
                         kGhostPickerRadius, kGhostPickerRadius)];
    UIImage *image = [UIImage imageNamed:@"circle1.png"];
    circle.image = image;
    [self addSubview:circle];
    circle.frame = CGRectMake(center.x - kGhostPickerRadius, center.y - kGhostPickerRadius,
                              2 * kGhostPickerRadius, 2 * kGhostPickerRadius);
    self.circleBackgroundView.frame = CGRectMake(center.x - kGhostPickerRadius, center.y - kGhostPickerRadius,
                                                 2*kGhostPickerRadius, 2*kGhostPickerRadius);
    
    self.defaultCenterView = circleBackgroundView;
    [self addSubview:circleBackgroundView];
    
}

- (void)displayMenuAnimated:(BOOL)animated {
    [self loadMenuIfNeeded];
    [self centerMenuItemsAndChangeAlpha:1.0];
    
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
    }
       [self displayCircle]; 
       [self layoutMenuItemsRadial];
    
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)dealloc {
    [defaultCenterView release];
    [circleBackgroundView release];
    [submenuItems release];
    [menuItems release];
    [circle release];
    [super dealloc];
}
- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark recognizer method

- (void)processMoveForPoint:(CGPoint)point {
    compomentNumber = -1;
    
    if (directionNumber >= 0) {
        CGRect rect = self.bounds;
        rect.origin.x = rect.size.width / 2;
        rect.origin.y = rect.size.height / 2;
        rect.size = CGSizeMake(1, 1);
        rect = CGRectInset(rect, -allowableOversight, -allowableOversight);
        if (CGRectContainsPoint(rect, point)) {
            UIView *v = [self.menuItems objectAtIndex:directionNumber];
            lastComponentNumber = -1;
            directionNumber = -1;
            
            [self centerMenuItemsAndChangeAlpha:1.0];
            [UIView beginAnimations:nil context:NULL];
            self.circleBackgroundView = defaultCenterView;
            [self moveSubMenusToFrame:v.frame alpha:0.0];
            [self layoutMenuItemsRadial];
            [UIView commitAnimations];
            return;
        }
        
        int count = [self.submenuItems count];
        for (int i = 0; i < count; i++) {
            UIView *v = [self.submenuItems objectAtIndex:i];
            CGRect rect = v.frame;

            if (CGRectContainsPoint(rect, point)) {
                if (i != lastComponentNumber) {
                    [delegate IOGhostPicker:self
                       highlightedComponent:i
                                inDirection:directionNumber
                                       view:v];
                
                }
                compomentNumber = i;
                lastComponentNumber = i;
                return;
            }
        }
    } else {
        int count = [self.menuItems count];
        for (int i = 0; i < count; i++) {
            UIView *v = [self.menuItems objectAtIndex:i];
            CGRect rect = v.frame;
            if (CGRectContainsPoint(rect, point)) {
                [self loadSubmenuItemsForDirection:i];
                [self moveSubMenusToFrame:rect alpha:0.0];
                
                [UIView beginAnimations:nil context:NULL];
                [self centerMenuItemsAndChangeAlpha:0.0];
                [self layoutSubMenuItemsRadialForDirection:i alpha:1.0];
                [UIView commitAnimations];
                
                directionNumber = i;
                return;
            }
        }
    }
}

- (void)methodForPressRecognizer:(UILongPressGestureRecognizer*)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
            [self processMoveForPoint:[sender locationInView:self]];
            break;
        case UIGestureRecognizerStateEnded:
            if (directionNumber >= 0 && compomentNumber >= 0) {
                [delegate IOGhostPicker:self didChooseComponent:compomentNumber inDirection:directionNumber];
            } else {
                [delegate IOGhostPicker:self cancelledChoosingInDirection:directionNumber];
            }
            break;
        case UIGestureRecognizerStateCancelled:
            [delegate IOGhostPicker:self cancelledChoosingInDirection:directionNumber];
            break;
        default:
            break;
    }
}

@end
