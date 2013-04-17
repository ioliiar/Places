//
//  GoogleStep.h
//  Place
//
//  Created by Iurii Oliiar on 4/16/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>

@interface GoogleStep : NSObject

@property (nonatomic, assign) CLLocationCoordinate2D start;
@property (nonatomic, assign) CLLocationCoordinate2D end;

@end
