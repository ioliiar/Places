//
//  WeaherView.m
//  Place
//
//  Created by Serhii on 5/22/13.
//  Copyright (c) 2013 Serhii. All rights reserved.
//

#import "WeaherView.h"
#import <QuartzCore/QuartzCore.h>

@interface WeaherView ()

@property (nonatomic) BOOL isVisible;

@end

@implementation WeaherView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
 
    }
    return self;
}

- (id) initWithPlaceName:(NSString*)aName weatherIcon:(UIImage*) aIcon tempetatureC:(NSInteger) temp {
    
    CGRect frame = CGRectMake(0, 10, 170, 150);
    
    self = [super initWithFrame:frame];
    if (self) {
    
        self.alpha = 0.8;
        self.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:189.0/255.0  blue: 243.0/255.0 alpha:1.f];
        self.layer.cornerRadius = 10.f;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width - 40, 20)];
        title.center = CGPointMake(self.frame.size.width/2, 20);
        title.textAlignment = NSTextAlignmentCenter;
        title.adjustsFontSizeToFitWidth = YES;
        title.backgroundColor = [UIColor clearColor];
        title.textColor = [UIColor whiteColor];
        title.text = aName;
        [self addSubview:title];
        
        UIImageView* iconWeatherImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width - 20, self.frame.size.height - 40)];
        iconWeatherImage.center = CGPointMake(self.frame.size.width/2 - 5, self.frame.size.height/2);
        iconWeatherImage.image = aIcon;
        iconWeatherImage.alpha = 1.f;
        [self addSubview:iconWeatherImage];
        
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, 50, 20)];
        tempLabel.backgroundColor = [UIColor clearColor];
        tempLabel.center = CGPointMake(self.frame.size.width/2, 130);
        tempLabel.textAlignment = NSTextAlignmentCenter;
        tempLabel.textColor = [UIColor whiteColor];
        tempLabel.text = [NSString stringWithFormat:@"%d °C", temp];
        [self addSubview:tempLabel];
        
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        [self setCenter:CGPointMake(screenSize.width + self.frame.size.width/2, self.frame.size.height/2 + 10)];
        
        
        UISwipeGestureRecognizer  *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                    initWithTarget:self
                                    action:@selector(didSwipe:)];
      
        leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        
        [self addGestureRecognizer:leftSwipeRecognizer];
    }
    return self;
}

- (id)init {
   
    return [self initWithPlaceName:nil weatherIcon:nil tempetatureC:0];
}

-(void)showOnView:(UIView *)superview {
    
    if( !self.isVisible ) {
        
        [superview addSubview:self];

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.alpha = 0.8;
        self.center = CGPointMake(superview.frame.size.width - (self.frame.size.width/2) + 10, superview.frame.origin.y + (self.frame.size.height/2 + 10));
        [UIView commitAnimations];
        self.isVisible = YES;

    }
}


- (void) didSwipe:(UIGestureRecognizer*) aReco {

    [self hide];

}

-(void)hide {
    
    if( self.isVisible ) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        self.alpha = 0.0;
        CGPoint modalCenter = CGPointMake(screenSize.width + self.frame.size.width/2, self.frame.size.height/2 + 10);
        self.center = modalCenter;
        [UIView commitAnimations];
        
        
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.75f];
        
        self.isVisible = NO;
        
        if([self.delegate respondsToSelector:@selector(modalUIViewDidHide:)]) {
            [self.delegate weatherViewDidHide:self];
        }
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) dealloc {

    [super dealloc];
   

}

@end
