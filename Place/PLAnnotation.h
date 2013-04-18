//
//  SLAnnotation.h
//  Slavske
//
//  Created by Serhii Nakonechnyi on 3/10/13.
//  Copyright (c) 2013 Serhii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface PLAnnotation : NSObject <MKAnnotation>

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
