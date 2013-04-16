//
//  PLPlaceManager.h
//  Place
//
//  Created by Serhii on 4/9/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PLPlaceManager : NSObject

+ (PLPlaceManager *)sharedPlaceManager;
- (NSArray *) sendRequestWithType:(NSString *)placeType
                      coordinates:(CLLocationCoordinate2D) coordinates
                           radius:(NSInteger) radius;

@end
