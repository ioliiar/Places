//
//  PLPlace.h
//  Place
//
//  Created by Serhii on 4/9/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PLPlace : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* vicinity;
@property (nonatomic, copy) NSString* iconLink;
@property (nonatomic, copy) NSArray* types;
@property (nonatomic, assign) float rating;
@property (nonatomic, copy) NSString* identifier;
@property (nonatomic, copy) NSString* reference;
@property (nonatomic, assign) BOOL* isOpenNow;

@end
