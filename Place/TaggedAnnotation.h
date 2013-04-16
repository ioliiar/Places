//
//  TaggedAnnotation.h
//  Place
//
//  Created by Iurii Oliiar on 4/16/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TaggedAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) NSInteger tag;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
