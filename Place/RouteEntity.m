//
//  RouteEntity.m
//  Place
//
//  Created by Iurii Oliiar on 4/1/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "RouteEntity.h"

@implementation RouteEntity

@synthesize Id;
@synthesize name;
@synthesize places;

- (id)init {
    self = [super init];
    if (self) {
        self.places = [[[NSMutableArray alloc] initWithCapacity:8] autorelease];
    }
    return self;
}

- (void)dealloc {
    [places release];
    [name release];
    [super dealloc];
}

@end
