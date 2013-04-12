//
//  PlaceEntity.h
//  Place
//
//  Created by Iurii Oliiar on 3/29/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlaceEntity : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *comment;

@property (nonatomic, retain) NSDate *dateVisited;
@property (nonatomic, retain) UIImage *photo;

@property (nonatomic, assign) NSInteger Id;
@property (nonatomic, assign) NSInteger category;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longtitude;

@end
