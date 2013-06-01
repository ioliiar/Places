//
//  PLPlaceManager.h
//  Place
//
//  Created by Serhii on 4/9/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class PLPlaceManager;

@protocol PLPlaceManagerDelegate <NSObject>

- (void) plaseManagerDidFinishWihError:(NSError*) aError;
- (void) plaseManagerDidFinishWithPlaces:(NSArray*) aPlaceEntities;

@end

@interface PLPlaceManager : NSObject

+ (PLPlaceManager *)sharedPlaceManager;
- (void) sendRequestWithType:(NSString *)placeType
                      coordinates:(CLLocationCoordinate2D) coordinates
                           radius:(NSInteger) radius;
@property (nonatomic, assign) id <PLPlaceManagerDelegate> delegate;

@end
