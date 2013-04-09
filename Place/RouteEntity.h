//
//  RouteEntity.h
//  Place
//
//  Created by Iurii Oliiar on 4/1/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteEntity : NSObject

@property (nonatomic, assign) NSInteger Id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSMutableArray *places;

@end
